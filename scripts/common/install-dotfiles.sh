#!/bin/bash

BOTH_DIR="both_config"
DESKTOP_DIR="desktop_config"
LAPTOP_DIR="laptop_config"

echo -e "\n${BLUE}### Deploying configurations to ~/.config ###${NC}"
cp -rT "$BOTH_DIR/" "$HOME/.config"
echo -e "${GREEN}All files copied.${NC}"

echo -e "\n${BLUE}### Checking device type... ###${NC}"

if [ "$device_type" == "1" ]; then
    echo -e "${GREEN}Desktop detected. Deploying desktop configs...${NC}"
    if [ -d "$DESKTOP_DIR" ]; then
        cp -rT "$DESKTOP_DIR/" "$HOME/.config"
        echo -e "${GREEN}All desktop files copied.${NC}"
    fi
elif [ "$device_type" == "2" ]; then
    echo -e "${GREEN}Laptop detected. Deploying laptop configs...${NC}"
    if [ -d "$LAPTOP_DIR" ]; then
        cp -rT "$LAPTOP_DIR/" "$HOME/.config"
        echo -e "${GREEN}All laptop files copied.${NC}"
    fi
fi

echo -e "\n${BLUE}### Moving 'ly' configuration to /etc/ ###${NC}"
if [ -d "$HOME/.config/ly" ]; then
    echo -e "${YELLOW}Moving ~/.config/ly to /etc/ly (requires sudo)${NC}"
    sudo cp -rT "$HOME/.config/ly/" "/etc/ly/" && rm -rf "$HOME/.config/ly"
fi

echo -e "\n${GREEN}### Dotfiles deployment complete! ###${NC}"
