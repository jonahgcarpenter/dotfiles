#!/bin/bash

# --- Configuration ---
# The directory within this repo where your config files are stored.
# This assumes the script is run from the root of your dotfiles repo.
SOURCE_DIR="config-files"

# --- Color Codes ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# --- Deployment Process ---

# 1. Copy all contents from the source directory to HOME
echo -e "\n${BLUE}### Deploying all configurations to ~/ ###${NC}"
# The -T option treats the destination as a normal directory, not a target
# for the source directory itself. This copies the *contents*.
cp -rT "$SOURCE_DIR/" "$HOME/"
echo "All files copied."

# 2. Move the 'ly' configuration from ~/.config to /etc/ly
echo -e "\n${BLUE}### Moving 'ly' configuration to /etc/ ###${NC}"
if [ -d "$HOME/.config/ly" ]; then
    # Move the newly copied ly directory to its final destination
    echo "Moving ~/.config/ly to /etc/ly (requires sudo)"
    sudo cp -rT "$HOME/.config/ly/" "/etc/ly/"
    rm -rf "$HOME/.config/ly"
else
    echo -e "${YELLOW}Warning: ~/.config/ly not found after copy. Cannot move to /etc/.${NC}"
fi

echo -e "\n${GREEN}### Dotfiles deployment complete! ###${NC}"
