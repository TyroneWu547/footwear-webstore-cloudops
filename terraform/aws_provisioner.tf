variable "key_name" {
    type = string
    default = "ssh-access"
    description = "key-pair filename"
}

resource "tls_private_key" "ssh_key_gen" {
    algorithm = "RSA"
    rsa_bits = 4096
}

resource "local_file" "key_pem_file" {
    filename = "./vault/${var.key_name}.pem"
    file_permission = "600"
    directory_permission = "700"
    sensitive_content = tls_private_key.ssh_key_gen.private_key_pem
}

resource "aws_key_pair" "ssh_key_pair" {
    key_name = var.key_name
    public_key = tls_private_key.ssh_key_gen.public_key_openssh
}

resource "aws_instance" "control-node" {
    ami = "ami-0149b2da6ceec4bb0"
    instance_type = "t2.micro"
    key_name = aws_key_pair.ssh_key_pair.key_name
    
    tags = {
        Name = "control-node"
        Description = "Kubernetes Control Plane"
    }
}