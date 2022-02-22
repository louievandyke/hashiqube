job "tech-radar-traefik" {
  datacenters = ["dc1"]

  group "svc" {
    count = 1

    network {
      mode = "bridge"

      port  "http"{
        to = 8080
      }
    }

    service {
      tags = [
        "traefik.http.routers.tech-radar.rule=Host(`tech-radar.localhost`)",
        "traefik.http.routers.tech-radar.entrypoints=web",
        "traefik.http.routers.tech-radar.tls=false",
        "traefik.enable=true",
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        port     = "http"
        timeout  = "5s"
      }


    }

    task "server" {

      driver = "docker"

      config {
        image = "industrieco/techradar"
        ports = ["http"]
      }

      resources {
        memory = 500 # MB
      }
    }
  }
}
