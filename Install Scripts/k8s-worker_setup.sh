#!/bin/bash

# Update and install dependencies
sudo yum update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

read -p "Enter IP and hostname for k8s master. It will be writen to /etc/hosts file. (Exaple: 192.168.124.69  k8s-master) " master
sudo bash -c "echo $master >> /etc/hosts"

read -p "Enter IP and hostname for k8s worker1: " worker1
sudo bash -c "echo $worker1 >> /etc/hosts"

read -p "Enter IP and hostname for k8s worker2: " worker2
sudo bash -c "echo $worker2 >> /etc/hosts"

# Disable SELinux
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# Disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

# Enable br_netfilter module
sudo modprobe br_netfilter
echo '1' | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

# Add the following kernel parameters, create a file and with following content
sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install containerd.io -y
sudo yum install docker-ce docker-ce-sli -y

sudo systemctl enable --now docker.service

containerd conﬁg default | sudo tee /etc/containerd/conﬁg.toml #>/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/conﬁg.toml

# Start and enable Docker
sudo systemctl enable containerd.service
sudo systemctl restart containerd.service

# Add Kubernetes repository
sudo cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# Install Kubernetes packages
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start kubelet
sudo systemctl enable --now kubelet
