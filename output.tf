# print app-server ip
output "public_ip" {
    value = aws_instance.public_server.public_ip
} 
# print db-server ip
output "private_ip" {
    value = aws_instance.private_server.private_ip
}  

  
