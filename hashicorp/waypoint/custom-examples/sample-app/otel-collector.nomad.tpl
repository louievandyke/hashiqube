job "otel-collector-gateway" {

  datacenters = ["dc1"]

  group "svc" {
    count = 1

    vault {
      policies  = ["otel"]
    }

    network {

      port "otlp-grpc" {
        to = 4317
      }

      port "otlp-http" {
        to = 4318
      }

      port "metrics" {
        to = 8888
      }

      # Receivers
      port "prom" {
        to = 9090
      }

    }

    service {
      tags = [
        "traefik.http.routers.collector.rule=Host(`otel-collector-http.localhost`)",
        "traefik.http.routers.collector.entrypoints=web",
        "traefik.http.routers.collector.tls=false",
        "traefik.enable=true",
      ]

      port = "otlp-http"

      // check {
      //   type     = "tcp"
      //   interval = "10s"
      //   port     = "otlp-grpc"
      //   timeout  = "5s"
      // }
    }


    service {
      name = "otel-collector-hc"
      port = "prom"
      tags = ["prom"]
    }

    service {
      name = "otel-agent-hc"
      port = "metrics"
      tags = ["metrics"]
    }

    task "svc" {
      driver = "docker"

      config {
        image = "${docker_artifact.image}:${docker_artifact.tag}"
        force_pull = true

        entrypoint = [
          "/otelcontribcol",
          "--config=local/config/otel-collector-config.yaml",
        ]
        ports = [
          "metrics",
          "prom",
          "otlp-grpc",
          "otlp-http"
        ]
      }


      resources {
        cpu    = 100
        memory = 512
      }

      template {
        data   = <<EOF

receivers:
  otlp:
    protocols:
      grpc:
      http:
        endpoint: "0.0.0.0:4318"

processors:
  batch:
    timeout: 10s
  memory_limiter:
    # 75% of maximum memory up to 4G
    limit_mib: 1536
    # 25% of limit up to 2G
    spike_limit_mib: 512
    check_interval: 5s

exporters:
  logging:
    logLevel: debug

service:
  pipelines:
    traces:
      receivers: [otlp]
      exporters: [logging]
EOF
        destination = "local/config/otel-collector-config.yaml"
      }
    }
  }
}