#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh ${ClusterName} ${BootstrapArguments}
echo "Updating log rotation size"
sed -i 's/"max-size":.*/"max-size": "1g",/g' /etc/docker/daemon.json
sed -i 's/"max-file":.*/"max-file": "2"/g' /etc/docker/daemon.json
systemctl restart docker