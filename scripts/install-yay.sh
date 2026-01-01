#!/bin/bash

set -e

echo "--- Starting installation of YAY ---"
echo ""

echo "--> Step 1: Installing required dependencies..."
sudo pacman -S --needed base-devel git

temp_dir=$(mktemp -d)

trap 'echo "--> Cleaning up temporary directory..."; rm -rf "$temp_dir"' EXIT

cd "$temp_dir"

echo "--> Step 2: Cloning YAY repository..."
git clone https://aur.archlinux.org/yay.git

cd yay

echo "--> Step 3: Building and installing YAY..."
makepkg -si

echo ""
echo "--- YAY has been successfully installed! ---"
