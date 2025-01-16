# Container Monitor

Container [monitoring script](templates/scripts/monitor.sh.j2) is present as a service to update Consul metadata with current state of a service.

It is triggered via `OnFailure` and `OnSuccess` in service `Unit` definition and updates the JSON service definition in `/etc/consul` based on currently used binary.
```
 > sudo systemctl -ocat status monitor-beacon-node-sepolia-stable.service
○ monitor-beacon-node-sepolia-stable.service - Monitor for beacon-node-sepolia-stable that updates Consul
     Loaded: loaded (/etc/systemd/system/monitor-beacon-node-sepolia-stable.service; enabled; vendor preset: enabled)
     Active: inactive (dead) since Mon 2024-03-11 13:41:54 UTC; 2s ago
       Docs: https://github.com/status-im/infra-role-beacon-node-linux
    Process: 2010090 ExecStart=/data/beacon-node-sepolia-stable/monitor.sh (code=exited, status=0/SUCCESS)
   Main PID: 2010090 (code=exited, status=0/SUCCESS)
        CPU: 42ms

Started Monitor for beacon-node-sepolia-stable that updates Consul.
Changes detected, reloading Consul.
monitor-beacon-node-sepolia-stable.service: Deactivated successfully.
```

# Known Issues

The method of modifying JSON files in `/etc/consul` using `sed` is crude but simple. It avoids the need to have to call [Consul Catalog API](https://developer.hashicorp.com/consul/api-docs/catalog#register-entity) with the whole set of service metadata only to update a single `ServiceMeta` key.

But there are a few problems with this approach:

* It only works for metadata fields that are already present in the JSON file.
* It causes Ansible to overwrite the fields, setting them to `unknown`.
* It can fail due to JSON file format changes.
