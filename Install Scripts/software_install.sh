#!/bin/bash

read -p "Press any key to continue"

read -p "Enter hostname you want to give to this host: " name

#sudo bash -c "echo $name > /etc/hostname"
sudo hostname set-hostname ${name}

sudo usermod -aG wheel $(whoami)

echo "Updating the repositories"
sudo yum update -y

echo "installing epel-release..."
sudo yum install epel-release -y

echo "epel-release installed. Pausing for package update..."
#sudo yum update -y > /dev/null 2>&1
sudo yum update -y

echo "Installing programs..."
sudo yum install vim shellcheck net-tools tldr bat \ 
  | wget htop tree neofetch tar zip open-vm-tools \ 
  | bash-completion NetworkManager-initscripts-updown -y

echo "All specified packages installed successfully."

# Use sed to uncomment the %wheel line in a safe way
sudo cp /etc/sudoers /etc/sudoers.bak

#sudo sed -i 's/^#\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD: ALL\)/\1/' /etc/sudoers
#sudo echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" >> /etc/sudoers

# Safely modify the sudoers file
if sudo grep -q '^#%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL' /etc/sudoers; then
    # Use sed to uncomment the line
    sudo sed -i 's/^#\(%wheel\s*ALL=(ALL)\s*NOPASSWD:\s*ALL\)/\1/' /etc/sudoers
else
    # Append if the line doesn't exist
    echo "%wheel  ALL=(ALL)       NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo
fi

read -p "Press any key to reboot"
sudo reboot now
