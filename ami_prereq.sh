#! /bin/bash
sudo mkdir -p /etc/systemd/system/docker.service.d/ && printf "[Service]\nExecStartPost=/sbin/iptables -P FORWARD ACCEPT" | sudo tee /etc/systemd/system/docker.service.d/10-iptables.conf
sudo apt-get update && sudo apt-get install -y docker.io
sudo systemctl enable docker
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo apt-add-repository 'deb http://apt.kubernetes.io/ kubernetes-xenial main'
sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl