resource "aws_instance" "app_server" {
  ami                    = "ami-0129bfde49ddb0ed6"
  instance_type          = "t3.medium"
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  key_name               = var.key_name
  
  tags = {
    Name = "AppServerInstance"
  }

  user_data = templatefile("user_data.sh", {
    AWS_REGION = var.aws_region
    AWS_ACCOUNT_ID = var.aws_account_id
    DOCKER_COMPOSE_CONTENT = templatefile("docker-compose.yml.tpl", {
      backend_image  = var.backend_image
      frontend_image = var.frontend_image
      postgres_db    = var.postgres_db
      postgres_user  = var.postgres_user
      postgres_password = var.postgres_password
      redis_port     = var.redis_port
      mongo_database = var.mongo_database
      redis_host     = var.redis_host
      redis_protocol = var.redis_protocol
      react_app_api_base_url = var.react_app_api_base_url
      default_server_cluster = var.default_server_cluster
    })
    NGINX_CONF_CONTENT = file("nginx.conf")
  })
}