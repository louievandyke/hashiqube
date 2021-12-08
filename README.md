# HashiQube with Traefik and Nomad/Vault Integration

This is a fork of the [`servian/hashiqube`](https://github.com/servian/hashiqube) repo.

I have made the following modifications:

1. I am only running Vault, Consul, and Nomad
2. I have replaced the [Fabio load balancer](https://fabiolb.net) with the [Traefik load balancer](traefik.io). The accompanying [traefik job](hashicorp/nomad/jobs/traefik.nomad) is deployed on provisioning Nomad.
3. I have updated the Nomad `server.conf` (see [`hashicorp/nomad.sh`](hashicorp/nomad.sh)) to give it the ability to pull Docker images from private GHCR repos by way of a GitHub Personal Access Token (PAT)
4. I have added Nomad/Vault integration. See [`hashicorp/nomad.sh`](hashicorp/nomad.sh) and [`hashicorp/vault.sh`](hashicorp/vault.sh)
5. I have added an [OpenTelemetry Collector job](hashicorp/nomad/jobs/otel-collector.nomad) to test the Vault/Nomad integration.

For more info, please see the following blog posts on Medium:
* [Just-in-Time Nomad: Running Traefik on Nomad with HashiQube](https://adri-v.medium.com/just-in-time-nomad-running-traefik-on-hashiqube-7d6dfd8ef9d8)