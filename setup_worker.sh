#---------------
# 1. run without sudo
# 2. you need nfs-server for uyuni-infra
#---------------

#!/bin/bash

cd ~

# disable firewall
sudo systemctl stop ufw
sudo systemctl disable ufw

# install basic packages
sudo apt install -y net-tools nfs-common whois

# network configuration
sudo modprobe overlay \
    && sudo modprobe br_netfilter

cat <<EOF | sudo tee -a /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

cat <<EOF | sudo tee -a /etc/sysctl.d/99-kubernetes-cri.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# nvidia-container-toolkit configuration
cat <<EOF | sudo tee /etc/docker/daemon.json
{
   "default-runtime": "nvidia",
   "runtimes": {
      "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
      }
   }
}
EOF

systemctl restart docker
sleep 30
