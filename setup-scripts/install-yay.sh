#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Announce the start of the script
echo "--- Starting installation of YAY ---"
echo ""

# 1. Install required dependencies
# The 'sudo' command will prompt for your password.
echo "--> Step 1: Installing required dependencies..."
sudo pacman -S --needed base-devel git

# 2. Clone the yay repository into a temporary directory
# This avoids leaving the 'yay' folder in your home directory.
# 'mktemp -d' creates a temporary directory and prints its name.
temp_dir=$(mktemp -d)

# 'trap' ensures that the temporary directory is removed when the script exits,
# even if it encounters an error.
trap 'echo "--> Cleaning up temporary directory..."; rm -rf "$temp_dir"' EXIT

cd "$temp_dir"

echo "--> Step 2: Cloning YAY repository..."
git clone https://aur.archlinux.org/yay.git

# 3. Build and install yay
cd yay

echo "--> Step 3: Building and installing YAY..."
# The '-s' flag installs needed dependencies for yay.
# The '-i' flag installs the yay package itself after building.
# Do NOT run makepkg with sudo. It will ask for sudo password when it needs to.
makepkg -si

echo ""
echo "--- YAY has been successfully installed! ---"
