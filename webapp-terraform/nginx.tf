resource "docker_image" "nginx" {
  name = "nginx:latest"
}

resource "docker_container" "nginx" {
  name  = "nginx"
  image = docker_image.nginx.image_id
  networks_advanced {
    name = docker_network.webapp_network.name
  }
  ports {
    internal = 80
    external = 80
  }
  volumes {
    host_path      = "${path.cwd}/nginx.conf"
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
}