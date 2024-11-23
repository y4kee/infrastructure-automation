output "public_ip" {
  value = aws_instance.Bash_Instance.public_ip
}

output "public_dns" {
  value = aws_instance.Bash_Instance.public_dns
}