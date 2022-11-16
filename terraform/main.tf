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

# Allow access to 'route' NodePort service
resource "aws_security_group" "nodeport_access" {
    name = "nodeport-access"
    description = "Open access to NodePort service"

    ingress {
        description = "Inbound rule for NodePort service"
        from_port = 30000
        to_port = 30000
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

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
        aws_security_group.nodeport_access.id
    ]

    tags = {
        Name = "control_node"
        Description = "Kubernetes control node"
    }
}

# # EC2 Instance: worker nodes
# resource "aws_instance" "worker_nodes" {
#     ami = var.worker_nodes_ec2.ami_type
#     instance_type = var.worker_nodes_ec2.instance_type
#     key_name = aws_key_pair.ssh_key_pair.key_name
#     vpc_security_group_ids = [ aws_security_group.ssh_internet_access.id ]

#     count = var.worker_nodes_ec2.instance_count

#     tags = {
#         Name = "worker_node"
#         Description = "Kubernetes worker nodes"
#     }
# }

# Generate inventory file for Ansible of the cluster
resource "local_file" "kube_cluster_hosts" {
    filename = "../ansible/inventory/inventory"
    content = templatefile(
        "../ansible/inventory/inventory-template.tftpl", 
        {
            database_server_ip = aws_instance.database_server.public_ip,
            control_node_ip = aws_instance.control_node.public_ip,
            # worker_nodes_ip = aws_instance.control_node.*.public_ip
            worker_nodes_ip = []
        }
    )
}
