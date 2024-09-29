#!/bin/bash

echo "Welcome to GitHub authentication setup for your server."

# Function to set up HTTPS login
setup_https() {
    echo "Setting up GitHub authentication via HTTPS."
    
    # Prompt for GitHub username and PAT
    read -p "Enter your GitHub username: " GITHUB_USERNAME
    read -sp "Enter your GitHub Personal Access Token: " GITHUB_TOKEN
    echo

    # Get the current git remote URL
    REMOTE_URL=$(git remote get-url origin)
    
    # Update the git remote to include the token for HTTPS authentication
    echo "Updating remote URL for HTTPS..."
    git remote set-url origin https://$GITHUB_USERNAME:$GITHUB_TOKEN@github.com/$GITHUB_USERNAME/$(basename `git rev-parse --show-toplevel`).git

    echo "Remote URL updated. You can now push to GitHub using HTTPS."
}

# Function to set up SSH login
setup_ssh() {
    echo "Setting up GitHub authentication via SSH."

    # Check if an SSH key already exists
    if [ -f "$HOME/.ssh/id_ed25519" ]; then
        echo "An SSH key already exists at ~/.ssh/id_ed25519."
    else
        # Generate SSH key
        echo "No SSH key found. Generating a new SSH key."
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)"
        echo "SSH key generated."
    fi

    # Display the SSH key and prompt the user to add it to GitHub
    echo "Here is your public SSH key. Copy it and add it to your GitHub account (https://github.com/settings/ssh/new)."
    cat ~/.ssh/id_ed25519.pub
    echo

    read -p "Have you added the SSH key to GitHub? (y/n): " CONFIRM
    if [[ "$CONFIRM" != "y" ]]; then
        echo "Please add your SSH key to GitHub and run this script again."
        exit 1
    fi

    # Test the SSH connection
    echo "Testing SSH connection to GitHub..."
    ssh -T git@github.com
    if [ $? -ne 1 ]; then
        echo "SSH connection failed. Please check your SSH setup."
        exit 1
    fi

    # Update the git remote to use SSH
    echo "Updating remote URL for SSH..."
    git remote set-url origin git@github.com:$(basename `git rev-parse --show-toplevel`).git

    echo "Remote URL updated. You can now push to GitHub using SSH."
}

# Function to cache credentials (optional)
cache_credentials() {
    echo "Do you want to cache your Git credentials for easier pushes? (y/n)"
    read -p "> " CACHE
    if [[ "$CACHE" == "y" ]]; then
        echo "Caching Git credentials for 1 hour..."
        git config --global credential.helper cache
        git config --global credential.helper 'cache --timeout=3600'
        echo "Git credentials will be cached for 1 hour."
    else
        echo "Skipping credential caching."
    fi
}

# Ask user which method they prefer
echo "How would you like to authenticate with GitHub?"
echo "1. HTTPS (with Personal Access Token)"
echo "2. SSH"
read -p "Select an option (1/2): " METHOD

# Execute the appropriate setup
if [[ "$METHOD" == "1" ]]; then
    setup_https
elif [[ "$METHOD" == "2" ]]; then
    setup_ssh
else
    echo "Invalid option selected. Exiting."
    exit 1
fi

# Optionally cache credentials
cache_credentials

echo "GitHub authentication setup complete. You can now use 'git push' to push to GitHub."
