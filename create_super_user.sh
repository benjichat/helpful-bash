#!/bin/bash

# Variables
NEW_USER="newusername"  # Change this to your desired username

# SSH Keys (paste your keys below, be sure to include the full key and any key names)
SSH_KEY_1="<ssh key 1>"
SSH_KEY_2="<ssh key 2>"

# Create the new user
sudo adduser $NEW_USER

# Add the new user to the sudo group
sudo usermod -aG sudo $NEW_USER

# Create the .ssh directory for the new user and set permissions
sudo mkdir -p /home/$NEW_USER/.ssh
sudo chmod 700 /home/$NEW_USER/.ssh

# Add the SSH keys to the authorized_keys file
echo $SSH_KEY_1 | sudo tee -a /home/$NEW_USER/.ssh/authorized_keys
echo $SSH_KEY_2 | sudo tee -a /home/$NEW_USER/.ssh/authorized_keys

# Set the appropriate permissions for the .ssh folder and the authorized_keys file
sudo chmod 600 /home/$NEW_USER/.ssh/authorized_keys
sudo chown -R $NEW_USER:$NEW_USER /home/$NEW_USER/.ssh

echo "User $NEW_USER created with sudo permissions and SSH keys added."
