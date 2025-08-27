#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# --- Update and install dependencies ---
sudo yum update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# --- Add IPs and hostnames ---
read -p "Enter IP and hostname for k8s master (e.g., 192.168.124.69 k8s-master): " master
sudo bash -c "echo $master >> /etc/hosts"

read -p "Enter IP and hostname for this worker: " worker
sudo bash -c "echo $worker >> /etc/hosts"

# --- Disable SELinux ---
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# --- Disable swap ---
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# --- Configure firewall ---
for port in 179 10250 30000-32767; do
    sudo firewall-cmd --permanent --add-port=${port}/tcp
done
# Uncomment only if VXLAN is needed
# sudo firewall-cmd --permanent --add-port=4789/udp
sudo firewall-cmd --reload

# --- Enable br_netfilter module ---
sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# --- Apply sysctl params ---
sudo tee /etc/sysctl.d/k8s.conf <<EOF
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# --- Install containerd ---
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y containerd.io

# --- Configure containerd ---
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl enable --now containerd

# --- Add Kubernetes repo ---
sudo tee /etc/yum.repos.d/kubernetes.repo <<EOF
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

# --- Install Kubernetes packages ---
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet

echo "Kubernetes worker node setup is complete."
echo "Please run 'kubeadm join' on this node with the token and hash provided by your control plane node."
