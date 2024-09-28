data "aws_ecr_authorization_token" "token" {}

provider "docker" {
  registry_auth {
    address  = data.aws_ecr_authorization_token.token.proxy_endpoint
    username = data.aws_ecr_authorization_token.token.user_name
    password = data.aws_ecr_authorization_token.token.password
  }
}

resource "docker_network" "webapp_network" {
  name = "webapp_network"
}

resource "docker_image" "postgres" {
  name = "postgres:latest"
}

resource "docker_container" "postgres" {
  name  = "postgres"
  image = docker_image.postgres.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}"
  ]
}

resource "docker_image" "redis" {
  name = "redis:latest"
}

resource "docker_container" "redis" {
  name  = "redis"
  image = docker_image.redis.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  ports {
    internal = var.redis_port
    external = var.redis_port
  }
}

resource "docker_image" "mongo" {
  name = "mongo:latest"
}

resource "docker_container" "mongo" {
  name  = "mongo"
  image = docker_image.mongo.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  env = [
    "MONGO_INITDB_DATABASE=${var.mongo_database}"
  ]
}

resource "docker_image" "backend" {
  name = var.backend_image
}


resource "docker_container" "backend" {
  name  = "backend"
  image = docker_image.backend.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  ports {
    internal = 8080
    external = 8080
  }
  env = [
    "POSTGRES_DB=${var.postgres_db}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "DATABASE_URL=jdbc:postgresql://postgres:5432/${var.postgres_db}",
    "REDIS_PROTOCOL=${var.redis_protocol}",
    "REDIS_HOST=${var.redis_host}",
    "REDIS_PORT=${var.redis_port}",
    "REACT_APP_API_BASE_URL=${var.react_app_api_base_url}",
    "MONGO_CURRENT_DATABASE=${var.mongo_database}",
    "DEFAULT_SERVER_CLUSTER=${var.default_server_cluster}"
  ]
  depends_on = [
    docker_container.postgres,
    docker_container.redis,
    docker_container.mongo
  ]
}

resource "docker_image" "frontend" {
  name = var.frontend_image
}


resource "docker_container" "frontend" {
  name  = "frontend"
  image = docker_image.frontend.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  ports {
    internal = 3000
    external = 3000
  }
  env = [
    "REACT_APP_API_BASE_URL=${var.react_app_api_base_url}"
  ]
}