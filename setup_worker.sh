#---------------
# 1. run without sudo
# 2. you need nfs-server for uyuni-infra
#---------------

#!/bin/bash

LOCAL_FILE_COPY=no
DOCKER_USER=
DOCKER_PW=

cd ~

# prevent auto upgrade
sudo sed -i 's/1/0/g' /etc/apt/apt.conf.d/20auto-upgrades

if [ -e /etc/needrestart/needrestart.conf ] ; then
	# disable outdated librareis pop up
	sudo sed -i "s/\#\$nrconf{restart} = 'i'/\$nrconf{restart} = 'a'/g" /etc/needrestart/needrestart.conf
	# disable kernel upgrade hint pop up
	sudo sed -i "s/\#\$nrconf{kernelhints} = -1/\$nrconf{kernelhints} = 0/g" /etc/needrestart/needrestart.conf 
fi

# install nvidia driver
sudo apt update
sudo apt install -y build-essential
sudo apt install -y linux-headers-generic
sudo apt install -y dkms

cat << EOF | sudo tee -a /etc/modprobe.d/blacklist.conf 
blacklist nouveau
blacklist lbm-nouveau
options nouveau modeset=0
alias nouveau off
alias lbm-nouveau off
EOF

echo options nouveau modeset=0 | sudo tee -a /etc/modprobe.d/nouveau-kms.conf
sudo update-initramfs -u

sudo rmmod nouveau

if [ ${LOCAL_FILE_COPY} == "yes" ] ; then
	scp root@192.168.1.59:/root/files/NVIDIA-Linux-x86_64-525.89.02.run .
else
        wget https://kr.download.nvidia.com/XFree86/Linux-x86_64/525.89.02/NVIDIA-Linux-x86_64-525.89.02.run
fi

sudo sh ~/NVIDIA-Linux-x86_64-525.89.02.run

nvidia-smi
nvidia-smi -L

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

# install docker
sudo apt update
sudo apt install -y ca-certificates curl gnupg lsb-release
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# login docker account
sudo docker login -u ${DOCKER_USER} -p ${DOCKER_PW}
systemctl restart docker
sleep 120

# install nvidia-container-toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID) \
    && curl -s -L https://nvidia.github.io/libnvidia-container/gpgkey | sudo apt-key add - \
    && curl -s -L https://nvidia.github.io/libnvidia-container/$distribution/libnvidia-container.list | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list

sudo apt-get update \
    && sudo apt-get install -y nvidia-container-toolkit

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
sleep 180
