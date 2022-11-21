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

# # VPC for Footwear app
# resource "aws_vpc" "footwear_vpc" {


#     tags = {
#         Name = ""
#     }
# }

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

    tags = {
        Name = "ssh-internet-access"
    }
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

    tags = {
        Name = "mysql-access"
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

    tags = {
        Name = "nodeport-access"
    }
}

# Ports used for microk8s https://microk8s.io/docs/services-and-ports
resource "aws_security_group" "microk8s_node_network" {
    name = "microk8s-node-network"
    description = "Ports used for node connection in microk8s"

    ingress {
        description = "microk8s api-server"
        from_port = 16443
        to_port = 16443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s kubelet"
        from_port = 10250
        to_port = 10250
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s kubelet"
        from_port = 10255
        to_port = 10255
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s cluster-agent"
        from_port = 25000
        to_port = 25000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s etcd"
        from_port = 12379
        to_port = 12379
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s kube-controller"
        from_port = 10257
        to_port = 10257
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s kube-scheduler"
        from_port = 10259
        to_port = 10259
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s dqlite"
        from_port = 19001
        to_port = 19001
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        description = "microk8s calico"
        from_port = 4789
        to_port = 4789
        protocol = "udp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "microk8s-node-network"
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
