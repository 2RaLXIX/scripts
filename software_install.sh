#!/bin/bash

read -p "Press [Enter] key to continue and install programms."

echo "Updating the repositories"
sudo yum update -y

echo "installing epel-release..."
sudo yum install epel-release -y > /dev/null 2>&1

echo "epel-release installed. Pausing for package update..."
sudo yum update -y

echo "Installing programs..."
sudo yum install vim net-tools tldr bat wget htop tree neofetch tar zip bash-completion NetworkManager-initscripts-updown -y

echo "All specified packages installed successfully."
