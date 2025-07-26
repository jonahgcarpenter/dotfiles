#!/bin/bash

set -e

echo "--- Starting and enabling Docker service ---"
# Start the Docker service for the current session.
sudo systemctl start docker.service

# Enable the Docker service to start automatically on system boot.
sudo systemctl enable docker.service
echo "Docker service started and enabled."
echo ""

echo "--- Adding current user to the 'docker' group ---"
# Add the current user ($USER) to the 'docker' group.
# This allows running docker commands without needing sudo.
sudo usermod -aG docker $USER
echo "User '$USER' added to the 'docker' group."
