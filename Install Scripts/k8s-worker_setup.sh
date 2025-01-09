#!/bin/bash

# Update and install dependencies
sudo yum update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

read -p "Enter IP and hostname for k8s master (e.g., 192.168.124.69 k8s-master): " master
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

# Add firewall rules
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=30000-32767/tcp
# Uncomment if needed for VXLAN
# sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

# Enable br_netfilter module
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Apply sysctl params without reboot
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Install containerd
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io

# Create default configuration file for containerd
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1

# Enable SystemdCgroup
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml

# Start and enable containerd
sudo systemctl enable containerd.service
sudo systemctl restart containerd.service

# Add Kubernetes repository
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
EOF

# Install Kubernetes packages
#sudo yum install -y kubelet kubeadm kubectl

sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

# Enable and start kubelet
sudo systemctl enable --now kubelet

echo "Kubernetes worker node setup is complete. Please run kubeadm join on this node with the token and hash provided by your control plane node."

