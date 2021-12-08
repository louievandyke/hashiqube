job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "service"

  group "svc" {
    count = 1

    network {
      mode = "host"

      port "http" {
        to = 80
        static = 80
      }

      port "api" {
        to = 8080
        static = 8080
      }

      port "metrics" {
        to     = 8082
        static = 8082
      }

    }

    service {
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.dashboard.rule=Host(`traefik.localhost`)",
        "traefik.http.routers.dashboard.service=api@internal",
        "traefik.http.routers.dashboard.entrypoints=web",
      ]

      port = "http"

      check {
        type     = "tcp"
        interval = "10s"
        timeout  = "5s"
      }
    }

    task "loadbalancer" {
      driver = "docker"

      config {
        network_mode = "host"
        image        = "traefik:v2.4"
        ports        = ["http", "api", "metrics"]

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.web]
    address = ":80"
    [entryPoints.metrics]
    address = ":8082"

[api]
    dashboard = true
    insecure  = true

[log]
    level = "DEBUG"
# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
    prefix           = "traefik"
    exposedByDefault = false

    [providers.consulCatalog.endpoint]
      address = "127.0.0.1:8500"
      scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}