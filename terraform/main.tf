# -----------------------------------------------------------------------------
# Private Key-pair
# -----------------------------------------------------------------------------

# Generate SSH key pair
resource "tls_private_key" "ssh_key_gen" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Write key to local pem file
resource "local_sensitive_file" "key_pem_file" {
    filename = "../vault/${var.key_name}.pem"
    content = tls_private_key.ssh_key_gen.private_key_pem
    file_permission = "0400"
}

# Use generated key-pair for SSH access to EC2 instances
resource "aws_key_pair" "ssh_key_pair" {
    key_name = var.key_name
    public_key = tls_private_key.ssh_key_gen.public_key_openssh
}

# -----------------------------------------------------------------------------
# AWS VPC
# -----------------------------------------------------------------------------

# VPC for Footwear app
resource "aws_default_vpc" "main" {
    tags = {
        Name = "main"
    }
}

# -----------------------------------------------------------------------------
# AWS Security Groups
# -----------------------------------------------------------------------------

# Security rules to allow SSH access to and internet traffic from
resource "aws_security_group" "ssh_internet_access" {
    name = "ssh-internet-access"
    description = "Basic in/out rules for EC2 instances"
    vpc_id = aws_default_vpc.main.id

    ingress {
        description = "Inbound rule for SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        description = "Outbound rule for internet"
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "ssh-internet-access"
    }
}

# Allow access to the exposed NodePort services
resource "aws_security_group" "nodeport_access" {
    name = "nodeport-access"
    description = "Open access to NodePort services"
    vpc_id = aws_default_vpc.main.id

    dynamic "ingress" {
        for_each = var.nodeport_ports
        content {
            description = ingress.value.description
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }

    tags = {
        Name = "nodeport-access"
    }
}

# Ports used for microk8s https://microk8s.io/docs/services-and-ports
resource "aws_security_group" "microk8s_node_network" {
    name = "microk8s-node-network"
    description = "Ports used for node connection in microk8s"
    vpc_id = aws_default_vpc.main.id

    dynamic "ingress" {
        for_each = var.microk8s_node_network_ports
        content {
            description = "Inbound ${ingress.value.description}"
            from_port = ingress.value.port
            to_port = ingress.value.port
            protocol = ingress.value.protocol
            self = true
        }
    }

    dynamic "egress" {
        for_each = var.microk8s_node_network_ports
        content {
            description = "Outbound ${egress.value.description}"
            from_port = egress.value.port
            to_port = egress.value.port
            protocol = egress.value.protocol
            self = true
        }
    }

    tags = {
        Name = "microk8s-node-network"
    }
}

# Allow access to MySQL database
resource "aws_security_group" "mysql_access" {
    name = "mysql-access"
    description = "Open access to mysql database"
    vpc_id = aws_default_vpc.main.id

    ingress {
        description = "Inbound rule for mysql"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        security_groups = ["${aws_security_group.microk8s_node_network.id}"]
    }

    tags = {
        Name = "mysql-access"
    }
}

# -----------------------------------------------------------------------------
# AWS EC2 Instances
# -----------------------------------------------------------------------------

# EC2 Instance: database server
resource "aws_instance" "database_server" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.db_ec2.instance_type
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [ 
        aws_security_group.ssh_internet_access.id,
        aws_security_group.mysql_access.id
    ]

    tags = {
        Name = "database_server"
        Description = "Database server"
    }
}

# EC2 Instance: control node
resource "aws_instance" "control_node" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.control_node_ec2.instance_type
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [
        aws_security_group.ssh_internet_access.id,
        aws_security_group.nodeport_access.id,
        aws_security_group.microk8s_node_network.id
    ]

    tags = {
        Name = "control_node"
        Description = "Kubernetes control node"
    }
}

# EC2 Instance: worker nodes
resource "aws_instance" "worker_nodes" {
    count = length(var.worker_nodes_ec2.ami_loc_types)
    # provider = "aws.${var.worker_nodes_ec2.ami_loc_types[count.index].location}"

    ami = data.aws_ami.ubuntu.id
    instance_type = var.worker_nodes_ec2.instance_type
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [
        aws_security_group.ssh_internet_access.id,
        aws_security_group.microk8s_node_network.id
    ]

    tags = {
        Name = "worker_node_${count.index}"
        Description = "Kubernetes worker node ${count.index}"
    }
}

# -----------------------------------------------------------------------------
# Ansible inventory file
# -----------------------------------------------------------------------------

# Generate inventory file for Ansible of the cluster
resource "local_file" "kube_cluster_hosts" {
    filename = "/home/host/ansible/inventory/inventory"
    content = templatefile(
        "/home/host/ansible/inventory/inventory-template.tftpl", 
        {
            database_server_ip = aws_instance.database_server.public_ip,
            control_node_ip = aws_instance.control_node.public_ip,
            worker_nodes_ip = aws_instance.worker_nodes.*.public_ip
        }
    )
}
