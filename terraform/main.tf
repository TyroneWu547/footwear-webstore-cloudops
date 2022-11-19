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
# AWS Security Groups
# -----------------------------------------------------------------------------

# Security rules to allow SSH access to and internet traffic from
resource "aws_security_group" "ssh_internet_access" {
    name = "ssh-internet-access"
    description = "Basic in/out rules for EC2 instances"

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

    # egress {
    #     description = "Outbound rule for HTTP"
    #     from_port = 80
    #     to_port = 80
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }
    # egress {
    #     description = "Outbound rule for HTTPS"
    #     from_port = 443
    #     to_port = 443
    #     protocol = "tcp"
    #     cidr_blocks = ["0.0.0.0/0"]
    # }
}

# Allow access to MySQL database
resource "aws_security_group" "mysql_access" {
    name = "mysql-access"
    description = "Open access to mysql database"

    ingress {
        description = "Inbound rule for mysql"
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Allow access to the exposed NodePort services
resource "aws_security_group" "nodeport_access" {
    name = "nodeport-access"
    description = "Open access to NodePort services"

    ingress {
        description = "Inbound rule for the Route microservice"
        from_port = 30000
        to_port = 30000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "Inbound rule for the microk8s dashboard"
        from_port = 31000
        to_port = 31000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Allow worker node to join master node
resource "aws_security_group" "microk8s_cluster_agent" {
    name = "microk8s-cluster-agent"
    description = "Allow worker node to join master node"

    ingress {
        description = "Inbound rule for control node where worker node joins."
        from_port = 25000
        to_port = 25000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Allow worker node to join master node
resource "aws_security_group" "microk8s_api_server" {
    name = "microk8s-api-server"
    description = "Pod network connection for microk8s"

    ingress {
        description = "Inbound rule for microk8s api-server."
        from_port = 16443
        to_port = 16443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# -----------------------------------------------------------------------------
# AWS EC2 Instances
# -----------------------------------------------------------------------------

# EC2 Instance: database server
resource "aws_instance" "database_server" {
    ami = var.db_ec2.ami_type
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
    ami = var.control_node_ec2.ami_type
    instance_type = var.control_node_ec2.instance_type
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [ 
        aws_security_group.ssh_internet_access.id,
        aws_security_group.nodeport_access.id,
        aws_security_group.microk8s_cluster_agent.id,
        aws_security_group.microk8s_api_server.id
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

    ami = var.worker_nodes_ec2.ami_loc_types[count.index].ami_type
    instance_type = var.worker_nodes_ec2.instance_type
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [
        aws_security_group.ssh_internet_access.id,
        aws_security_group.microk8s_api_server.id
    ]

    tags = {
        Name = "worker_node_${count.index}_${var.worker_nodes_ec2.ami_loc_types[count.index].location}"
        Description = "Kubernetes worker node ${count.index} in ${var.worker_nodes_ec2.ami_loc_types[count.index].location}"
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
            # worker_nodes_ip = []
        }
    )
}
