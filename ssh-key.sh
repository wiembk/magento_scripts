#!/bin/bash

# Ask for the comment
echo "Enter a comment for the SSH key:"
read key_comment

# Generate an SSH key with the provided comment
ssh-keygen -t rsa -b 2048 -C "$key_comment"

# Start the SSH agent in the background
eval $(ssh-agent -s)

# Add your SSH key to the ssh-agent
ssh-add ~/.ssh/id_rsa

# Display the public key
echo -e "\033[0;32m$(cat ~/.ssh/id_rsa.pub)\033[0m"
