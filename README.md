# Description

This role provisions a [Nimbus Light Client](https://nimbus.guide/el-light-client.html) installation that can act as an ETH2 network beacon node.

# Introduction

The role will:

* Checkout a branch from the [nimbus-eth2](https://github.com/status-im/nimbus-eth2) repo
* Build it using the [`build.sh`](./templates/scripts/build.sh.j2) Bash script
* Schedule regular builds using [Systemd timers](https://www.freedesktop.org/software/systemd/man/systemd.timer.html)
* Start a node by defining a [Systemd service](https://www.freedesktop.org/software/systemd/man/systemd.service.html)

# Ports

The service exposes this port by default:

* `9500` - LibP2P peering port. Must __ALWAYS__ be public.

# Installation

Add to your `requirements.yml` file:
```yaml
- name: infra-role-nimbus-light-client
  src: git+git@github.com:status-im/infra-role-nimbus-light-client.git
  scm: git
```

# Configuration

The crucial settings are:
```yaml
# branch which should be built
light_client_repo_branch: 'stable'
# ethereum network to connect to
light_client_network: 'mainnet'
# optional setting for debug mode
light_client_log_level: 'DEBUG'
```
There's also a [container monitor service](./MONITOR.md).
```yaml
nim_waku_monitor_enabled: true
```
Most non-sensitive configuration resides in `conf/config.toml` file in service directory.

# Management

## Service

Assuming the `stable` branch was built you can manage the service with:
```sh
sudo systemctl start light-client-mainnet-stable
sudo systemctl status light-client-mainnet-stable
sudo systemctl stop light-client-mainnet-stable
```
You can view logs under:
```sh
tail -f /data/light-client-mainnet-stable/logs/service.log
```
All node data is located in `/data/light-client-mainnet-stable/data`.

## Builds

A timer will be installed to build the image:
```sh
 > sudo systemctl list-units --type=service '*light-client-*'
  UNIT                                LOAD   ACTIVE SUB     DESCRIPTION
  light-client-prater-stable.service   loaded active running Light Client Node on prater network (stable)
  light-client-prater-testing.service  loaded active running Light Client Node on prater network (testing)
  light-client-unstable.service loaded active running Nimbus Light Client on prater network (unstable)
```
To rebuild the image:
```sh
 > sudo systemctl start build-light-client-prater-stable
 > sudo systemctl status build-light-client-prater-stable
 ● light-client-prater-stable-build.service - Build light-client-prater-stable
     Loaded: loaded (/etc/systemd/system/light-client-prater-stable-build.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Wed 2021-09-29 12:00:12 UTC; 2h 15min ago
TriggeredBy: ● light-client-prater-stable-build.timer
       Docs: https://github.com/status-im/infra-role-systemd-timer
    Process: 1212987 ExecStart=/data/light-client-prater-stable/build.sh (code=exited, status=0/SUCCESS)
   Main PID: 1212987 (code=exited, status=0/SUCCESS)

Sep 29 12:00:12 build.sh[1213054]: HEAD is now at 0b21ebfe readme: update toc
Sep 29 12:00:12 build.sh[1212987]:  >>> Binary already built
Sep 29 12:00:12 systemd[1]: light-client-prater-stable-build.service: Succeeded.
Sep 29 12:00:12 systemd[1]: Finished Build light-client-prater-stable.
```
To check full build logs use:
```sh
journalctl -u build-light-client-mainnet-stable.service
```

# Requirements

Due to being part of Status infra this role assumes availability of certain things:

* The `iptables-persistent` module
