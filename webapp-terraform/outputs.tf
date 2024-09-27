output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.app_server.public_ip
}

output "application_url" {
  value = "http://${aws_instance.app_server.public_ip}"
}