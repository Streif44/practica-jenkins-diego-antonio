terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.1"
    }
  }
}

provider "docker" {
  host = "npipe:////.//pipe//docker_engine"
} # Para Windows, añadir: host = "npipe:////.//pipe//docker_engine"


resource "docker_image" "dind" {
  name         = "docker:dind"
  keep_locally = false
}

resource "docker_image" "myjenkins-python" {
  name         = "myjenkins-python"
  keep_locally = false
}

resource "docker_volume" "jenkins-docker-certs" {
  name = "jenkins-docker-certs"
}

resource "docker_volume" "jenkins-data" {
  name = "jenkins-data"
}

resource "docker_network" "jenkins-net" {
  name = "jenkins-net"
}


resource "docker_container" "jenkins_docker" {
  name  = "jenkins-docker"
  image = docker_image.dind.image_id
  privileged = true

  ports {
    internal = 2376
    external = 2376
  }

  volumes {
    volume_name    = docker_volume.jenkins-data.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name    = docker_volume.jenkins-docker-certs.name
    container_path = "/certs"
  }

  networks_advanced {
    name    = docker_network.jenkins-net.name
    aliases = ["docker"]
  }


  env = [
    "DOCKER_TLS_CERTDIR=/certs"
  ]

}

resource "docker_container" "jenkins_python" {
  name  = "jenkins-python"
  image = docker_image.myjenkins-python.image_id

  restart = "on-failure"

  ports {
    internal = 8080
    external = 8080
  }

  ports {
    internal = 50000
    external = 50000
  }

  volumes {
    volume_name    = docker_volume.jenkins-data.name
    container_path = "/var/jenkins_home"
  }

  volumes {
    volume_name    = docker_volume.jenkins-docker-certs.name
    container_path = "/certs/client"
	read_only = true
  }

  networks_advanced {
    name = docker_network.jenkins-net.name
  }


  env = [
    "DOCKER_HOST=tcp://docker:2376",
    "DOCKER_CERT_PATH=/certs/client",
    "DOCKER_TLS_VERIFY=1"
  ]

} 