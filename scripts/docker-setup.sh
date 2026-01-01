#!/bin/bash

set -e

echo "--- Starting and enabling Docker service ---"
sudo systemctl start docker.service

sudo systemctl enable docker.service

sudo usermod -aG docker $USER
echo "User '$USER' added to the 'docker' group."
