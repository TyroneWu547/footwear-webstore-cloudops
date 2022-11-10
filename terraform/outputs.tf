# Output public IP of control_node
output "ec2_public_ip" {
    value = aws_instance.control_node.public_ip
}
