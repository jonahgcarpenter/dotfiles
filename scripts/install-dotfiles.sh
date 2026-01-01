#!/bin/bash

BOTH_DIR="both_config"
DESKTOP_DIR="desktop_config"
LAPTOP_DIR="laptop_config"

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\n${BLUE}### Deploying configurations to ~/.config ###${NC}"
cp -rT "$BOTH_DIR/" "$HOME/.config"
echo "All files copied."

echo -e "\n${BLUE}### Checking device type... ###${NC}"

if [ "$device_type" == "1" ]; then
    echo -e "${GREEN}Desktop detected. Deploying desktop configs...${NC}"
    if [ -d "$DESKTOP_DIR" ]; then
        cp -rT "$DESKTOP_DIR/" "$HOME/.config"
        echo "All desktop files copied."
    fi
elif [ "$device_type" == "2" ]; then
    echo -e "${GREEN}Laptop detected. Deploying laptop configs...${NC}"
    if [ -d "$LAPTOP_DIR" ]; then
        cp -rT "$LAPTOP_DIR/" "$HOME/.config"
        echo "All laptop files copied."
    fi
fi

echo -e "\n${BLUE}### Moving 'ly' configuration to /etc/ ###${NC}"
if [ -d "$HOME/.config/ly" ]; then
    echo "Moving ~/.config/ly to /etc/ly (requires sudo)"
    sudo cp -rT "$HOME/.config/ly/" "/etc/ly/" && rm -rf "$HOME/.config/ly"
fi

echo -e "\n${GREEN}### Dotfiles deployment complete! ###${NC}"
