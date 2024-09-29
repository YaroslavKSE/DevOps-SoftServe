# Frontend EC2 Instance
resource "aws_instance" "frontend" {
  ami                         = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.frontend_sg.id]
  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  user_data = templatefile("scripts/frontend_userdata.sh.tpl", {
    backend_private_ip = aws_instance.backend.private_ip,
    artifacts_bucket   = aws_s3_bucket.artifacts.bucket
  })  

  tags = {
    Name = "frontend_instance"
  }
}

# Backend EC2 Instance
resource "aws_instance" "backend" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = var.key_pair_name

  user_data = templatefile("scripts/backend_userdata.sh.tpl", {
    postgres_private_ip = aws_instance.postgres.private_ip,
    redis_private_ip    = aws_instance.redis.private_ip,
    mongo_private_ip    = aws_instance.mongodb.private_ip,
    artifacts_bucket    = aws_s3_bucket.artifacts.bucket
  })  

  tags = {
    Name = "backend_instance"
  }
}

# Postgres EC2 Instance
resource "aws_instance" "postgres" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = var.key_pair_name

  user_data = templatefile("scripts/postgres_userdata.sh.tpl", {
    backend_private_ip = aws_instance.backend.private_ip,
    artifacts_bucket   = aws_s3_bucket.artifacts.bucket
  })

  tags = {
    Name = "postgres_instance"
  }
}

# MongoDB EC2 Instance
resource "aws_instance" "mongodb" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "mongodb_instance"
  }
}

# Redis EC2 Instance
resource "aws_instance" "redis" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.default.id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.redis_sg.id]
  key_name               = var.key_pair_name

  tags = {
    Name = "redis_instance"
  }
}
