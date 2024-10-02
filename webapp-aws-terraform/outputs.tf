output "frontend_public_ip" {
  description = "Public IP address of the frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

output "instance_ids_map" {
  description = "Map of EC2 instance IDs with names"
  value = {
    frontend = aws_instance.frontend.id,
    backend  = aws_instance.backend.id,
    postgres = aws_instance.postgres.id,
    mongodb  = aws_instance.mongodb.id,
    redis    = aws_instance.redis.id
  }
}

output "private_ips_map" {
  description = "Map of EC2 private IPs with names"
  value = {
    frontend = aws_instance.frontend.private_ip,
    backend  = aws_instance.backend.private_ip,
    postgres = aws_instance.postgres.private_ip,
    mongodb  = aws_instance.mongodb.private_ip,
    redis    = aws_instance.redis.private_ip
  }
}
