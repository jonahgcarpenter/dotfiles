#!/bin/bash

set -e

echo "--- Starting and enabling Docker service ---"
sudo systemctl start docker.service

sudo systemctl enable docker.service
echo "Docker service started and enabled."
echo ""

echo "--- Adding current user to the 'docker' group ---"
sudo usermod -aG docker $USER
echo "User '$USER' added to the 'docker' group."
