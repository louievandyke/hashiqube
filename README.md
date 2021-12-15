# HashiQube with Traefik and Nomad/Vault Integration

This is a fork of the [`servian/hashiqube`](https://github.com/servian/hashiqube) repo.

I have made the following modifications:

1. I am only running Vault, Consul, and Nomad
2. I have replaced the [Fabio load balancer](https://fabiolb.net) with the [Traefik load balancer](traefik.io). The accompanying [traefik job](hashicorp/nomad/jobs/traefik.nomad) is deployed on provisioning Nomad.
3. I have updated the Nomad `server.conf` (see [`hashicorp/nomad.sh`](hashicorp/nomad.sh)) to give it the ability to pull Docker images from private GHCR repos by way of a GitHub Personal Access Token (PAT)
4. I have added Nomad/Vault integration. See [`hashicorp/nomad.sh`](hashicorp/nomad.sh) and [`hashicorp/vault.sh`](hashicorp/vault.sh)
5. I have added an [OpenTelemetry Collector job](hashicorp/nomad/jobs/otel-collector.nomad) to test the Vault/Nomad integration.
6. I have added a sample [2048-game](hashicorp/nomad/jobs/2048-game.nomad) job as a simple Nomad jobspec for testing purposes.

## Pre-requisites

* [Oracle VirtualBox](https://www.googleadservices.com/pagead/aclk?sa=L&ai=DChcSEwjVuPag0oL0AhXFnrMKHRjODRYYABAAGgJxbg&ohost=www.google.com&cid=CAASEuRoonvAcnwV4Mde6j85eTiOEQ&sig=AOD64_1N8BIxbnQDEjTDYvtzMR78syE9Bg&q&adurl&ved=2ahUKEwiUpe6g0oL0AhVjTd8KHWTvAkEQ0Qx6BAgCEAE) (version 6.1.30 at the time of this writing)
* [Vagrant](https://www.vagrantup.com/) (version 2.2.19 at the time of this writing)
* [A GitHub Personal Access Token (PAT)](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

## Quickstart

To get started:

1. Clone the repo

    ```bash
    git clone git@github.com:avillela/hashiqube.git
    ```

2. Start Vagrant

    ```bash
    cd hashiqube
    vagrant up
    ```
## Detailed How-To Guides

For detailed tutorials, please see the following blog posts on Medium:
* [Just-in-Time Nomad: Running Traefik on Nomad with HashiQube](https://adri-v.medium.com/just-in-time-nomad-running-traefik-on-hashiqube-7d6dfd8ef9d8)
* [Just-in-Time Nomad: Running the OpenTelemetry Collector on Hashicorp Nomad with HashiQube](https://adri-v.medium.com/just-in-time-nomad-running-the-opentelemetry-collector-on-hashicorp-nomad-with-hashiqube-4eaf009b8382)

## Gotchas

### DNS Resolution Issues with *.localhost

If you're using a Mac and are running into issues getting your machine to resolve `*.localhost`, try this: 

1. Install dnsmasq

    ```bash
    brew install dnsmasq
    ```

2. Configure

    Copy the sample config file to /usr/local/etc/dnsmasq.conf, and add address=/localhost/127.0.0.1 to it

    ```bash
    cp $(brew list dnsmasq | grep dnsmasq.conf) /usr/local/etc/dnsmasq.conf
    echo "address=/localhost/127.0.0.1" >> /usr/local/etc/dnsmasq.conf
    ```

    Restart dnsmasq services
    
    ```bash
    sudo brew services restart dnsmasq
    ```

    Add a resolver to allow OS X to resolve requests from `*.localhost`
    
    ```bash
    sudo mkdir /etc/resolver
    sudo touch /etc/resolver/localhost
    sudo echo "nameserver 127.0.0.1" >> /etc/resolver/localhost
    ```

3. Test
    
    Even though foo.localhost doesn’t exist, we should now be able to ping it, since it will map to 127.0.0.1, as per our configs above.
    
    ```bash
    ping foo.localhost
    ```

    Result:
    
    ```
    PING foo.localhost (127.0.0.1): 56 data bytes
    64 bytes from 127.0.0.1: icmp_seq=0 ttl=64 time=0.035 ms
    64 bytes from 127.0.0.1: icmp_seq=1 ttl=64 time=0.111 ms
    64 bytes from 127.0.0.1: icmp_seq=2 ttl=64 time=0.092 ms
    ...
    — — foo.localhost ping statistics — -
    3 packets transmitted, 3 packets received, 0.0% packet loss
    round-trip min/avg/max/stddev = 0.035/0.079/0.111/0.032 ms
    ```