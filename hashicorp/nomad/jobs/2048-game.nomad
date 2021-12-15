job "2048-game" {
  type        = "service"
  datacenters = ["dc1"]

  group "game" {
    count = 1 # number of instances

    network {
      mode = "bridge"

      port "http" {
        to = 80
      }
    }

    service {
      tags = [
        "traefik.http.routers.2048-game.rule=Host(`2048-game.localhost`)",
        "traefik.http.routers.2048-game.entrypoints=web",
        "traefik.http.routers.2048-game.tls=false",
        "traefik.enable=true",
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }
 
    task "2048" {
      driver = "docker"
 
      config {
        image = "alexwhen/docker-2048"

        ports = ["http"]
      }

      resources {
        cpu    = 500 # MHz
        memory = 256 # MB
      }
    }
  }
}