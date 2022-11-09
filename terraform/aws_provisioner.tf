variable "key_name" {
    type = string
    default = "ec2-ssh-key"
    description = "key-pair filename"
}

# Generate SSH key pair
resource "tls_private_key" "ssh_key_gen" {
    algorithm = "RSA"
    rsa_bits = 4096
}

# Write key to local pem file
resource "local_sensitive_file" "key_pem_file" {
    filename = "./vault/${var.key_name}.pem"
    content = tls_private_key.ssh_key_gen.private_key_pem
    file_permission = "0400"
}

# Use generated key-pair for SSH access to EC2 instance
resource "aws_key_pair" "ssh_key_pair" {
    key_name = var.key_name
    public_key = tls_private_key.ssh_key_gen.public_key_openssh
}

# Allow SSH access to EC2 instance
resource "aws_security_group" "ssh_access" {
    name = "ssh-access"
    description = "Allow SSH access from Internet"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Create EC2 instance
resource "aws_instance" "control_node" {
    ami = "ami-01d08089481510ba2"           # https://cloud-images.ubuntu.com/locator/ec2/
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    vpc_security_group_ids = [ aws_security_group.ssh_access.id ]

    tags = {
        Name = "control_node"
        Description = "Kubernetes Control Plane"
    }
}

# Output public IP of the EC2 instance
output publicip {
    value = aws_instance.control_node.public_ip
}