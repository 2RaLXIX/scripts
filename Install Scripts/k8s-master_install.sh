#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# --- Update and install dependencies ---
sudo yum update -y
sudo yum install -y yum-utils device-mapper-persistent-data lvm2

# --- Add IPs and hostnames ---
read -p "Enter IP and hostname for k8s master (e.g., 192.168.124.69 k8s-master): " master
sudo bash -c "echo $master >> /etc/hosts"

read -p "Enter IP and hostname for k8s worker1: " worker1
sudo bash -c "echo $worker1 >> /etc/hosts"

read -p "Enter IP and hostname for k8s worker2: " worker2
sudo bash -c "echo $worker2 >> /etc/hosts"

# --- Disable SELinux ---
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

# --- Disable swap ---
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# --- Configure firewall ---
for port in 6443 2379-2380 10250 10251 10259 10257 179; do
    sudo firewall-cmd --permanent --add-port=${port}/tcp
done
# Uncomment only if needed for VXLAN
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

# --- Initialize Kubernetes master ---
sudo kubeadm init --control-plane-endpoint=k8s-master

# --- Configure kubeconfig for current user ---
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# --- Install Pod network (Calico) ---
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

# --- Prompt for PV size ---
read -p "Enter the size of the PersistentVolume in GB (e.g., 10): " pv_size

# Validate number
if ! [[ "$pv_size" =~ ^[0-9]+$ ]]; then
  echo "Error: Please enter a valid number."
  exit 1
fi

# --- Create PersistentVolume ---
cat <<EOF > pv.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: local-pv
spec:
  capacity:
    storage: ${pv_size}Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: /mnt/data
EOF

sudo mkdir -p /mnt/data
sudo chown $(id -u):$(id -g) /mnt/data
kubectl apply -f pv.yaml

echo "PersistentVolume of ${pv_size}Gi has been created."
echo "Kubernetes master node setup is complete."
