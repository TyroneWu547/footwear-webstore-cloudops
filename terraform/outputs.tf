# Public IP of control_node
output "control_node_ip" {
    value = aws_instance.control_node.public_ip
}

# Public IP of database_server
output "database_server_ip" {
    value = aws_instance.database_server.public_ip
}

output "database_server_private_ip" {
    value = aws_instance.database_server.private_ip
}
