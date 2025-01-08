#!/bin/bash

read -p "Press any key to continue"

read -p "Enter hostname you want to give to this host: " name

sudo echo $name > /etc/hostname

echo "Updating the repositories"
sudo yum update -y

echo "installing epel-release..."
sudo yum install epel-release -y > /dev/null 2>&1

echo "epel-release installed. Pausing for package update..."
sudo yum update -y > /dev/null 2>&1

echo "Installing programs..."
sudo yum install vim net-tools tldr bat wget htop tree neofetch tar zip open-vm-tools bash-completion NetworkManager-initscripts-updown -y

echo "All specified packages installed successfully."

# Use sed to uncomment the %wheel line in a safe way
sudo cp /etc/sudoers /etc/sudoers.bak
sudo sed -i 's/^#\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD: ALL\)/\1/' /etc/sudoers

read -p "Press any key to reboot"
sudo reboot now
