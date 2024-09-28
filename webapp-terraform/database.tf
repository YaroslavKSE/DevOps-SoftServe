resource "null_resource" "database_restore" {
  depends_on = [aws_instance.app_server]

  provisioner "remote-exec" {
    inline = [
      "bash /home/ec2-user/app/scripts/restore_database.sh postgres ${var.db_dump_path}"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file(var.private_key)
    host        = aws_instance.app_server.public_ip
  }
}

variable "db_dump_path" {
  description = "Path to the database dump file"
  type        = string
}