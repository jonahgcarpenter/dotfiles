#!/bin/bash

set -e

echo -e "${BLUE}--- Starting and enabling Docker service ---${NC}"
sudo systemctl start docker.service

sudo systemctl enable docker.service

sudo usermod -aG docker $USER
echo -e "${GREEN}User '$USER' added to the 'docker' group.${NC}"
echo -e "${YELLOW}This will take affect after logout${NC}"
