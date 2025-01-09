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

# Add firewall ports
sudo firewall-cmd --permanent --add-port=6443/tcp
sudo firewall-cmd --permanent --add-port=2379-2380/tcp
sudo firewall-cmd --permanent --add-port=10250/tcp
sudo firewall-cmd --permanent --add-port=10251/tcp
sudo firewall-cmd --permanent --add-port=10259/tcp
sudo firewall-cmd --permanent --add-port=10257/tcp
sudo firewall-cmd --permanent --add-port=179/tcp
sudo firewall-cmd --permanent --add-port=4789/udp

sudo firewall-cmd --reload

# Enable br_netfilter module
#sudo modprobe br_netfilter
#echo '1' | sudo tee /proc/sys/net/bridge/bridge-nf-call-iptables

sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netﬁlter
EOF

sudo modprobe overlay
sudo modprobe br_netﬁlter

# Start and enable Docker
sudo systemctl enable --now containerd.service

sudo cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF

sudo sysctl --system

# Install Docker
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install containerd.io -y
#sudo yum install docker-ce docker-ce-sli -y

#sudo systemctl enable --now docker.service

containerd conﬁg default | sudo tee /etc/containerd/conﬁg.toml >/dev/null 2>&1

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

# Set up kubeconfig for the root user
echo "KUBECONFIG=/etc/kubernetes/admin.conf" >> ~/.bashrc
source ~/.bashrc

#sudo kubeadm init --pod-network-cidr=192.168.124.0/24
sudo kubeadm init --control-plane-endpoint=k8s-master

# Set up kubeconfig for a non-root user (uncomment and replace "yourusername" with your actual username)
mkdir -p $HOME/.kube
sudo cp /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Install a Pod network add-on (Calico for this example)

#kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml

echo "Kubernetes master node setup is complete."
