#!/bin/bash

read -p "Please enter hostname for this vm and continue to install programms." hostname
sudo echo "$hostname" >> /etc/hostname

echo "Updating the repositories"
sudo yum update -y

echo "installing epel-release..."
sudo yum install epel-release -y > /dev/null 2>&1

echo "epel-release installed. Pausing for package update..."
sudo yum update -y

echo "Installing programs..."
sudo yum install vim net-tools tldr bat wget htop tree neofetch tar zip bash-completion NetworkManager-initscripts-updown -y

echo "All specified packages installed successfully."

read -p "Press any key to reboot"
sudo reboot now
