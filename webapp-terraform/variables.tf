variable "postgres_db" {}
variable "postgres_user" {}
variable "postgres_password" {}
variable "redis_port" {}
variable "mongo_database" {}
variable "redis_host" {}
variable "redis_protocol" {}
variable "default_server_cluster" {}
variable "react_app_api_base_url" {}
variable "backend_image" {
  default = "730335443082.dkr.ecr.eu-north-1.amazonaws.com/schedule-web-app-backend:19.09.2024"
}

variable "frontend_image" {
  default = "730335443082.dkr.ecr.eu-north-1.amazonaws.com/schedule-web-app-frontend:19.09.2024"
}
