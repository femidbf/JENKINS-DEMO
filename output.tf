# output "femi_Jenkins_server" {
#     value = aws_instance.femi_Jenkins_server.public_ip
  
# }

output "femi1_Ansible_server" {
    value = aws_instance.femi1_Ansible_server.public_ip
  
}

output "femi1_Hostserver" {
    value = aws_instance.femi1_Hostserver.public_ip
  
}