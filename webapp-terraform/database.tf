resource "null_resource" "database_restore" {
  depends_on = [docker_container.postgres, docker_container.backend]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/restore_database.sh ${docker_container.postgres.name} ${var.db_dump_path}"
    environment = {
      DB_NAME = var.postgres_db
      DB_USER = var.postgres_user
      DB_PASSWORD = var.postgres_password
    }
  }
}

variable "db_dump_path" {
  description = "Path to the database dump file"
  type        = string
}