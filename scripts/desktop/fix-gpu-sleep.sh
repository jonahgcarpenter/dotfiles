#!/bin/bash

set -e

PARAM="nvidia.NVreg_PreserveVideoMemoryAllocations=1"
GRUB_FILE="/etc/default/grub"

echo -e "${BLUE}--- Starting NVIDIA Sleep Fix ---${NC}"
echo ""

if grep -q "$PARAM" "$GRUB_FILE"; then
    echo -e "${GREEN}--- Kernel parameter already exists in $GRUB_FILE. Skipping edit. ---${NC}"
else
    echo -e "${BLUE}Adding kernel parameter to $GRUB_FILE...${NC}"
    
    sudo cp "$GRUB_FILE" "$GRUB_FILE.bak"
    
    sudo sed -i "s/GRUB_CMDLINE_LINUX_DEFAULT=\"/GRUB_CMDLINE_LINUX_DEFAULT=\"$PARAM /" "$GRUB_FILE"
fi

echo -e "${BLUE}Updating GRUB configuration...${NC}"
sudo grub-mkconfig -o /boot/grub/grub.cfg

echo -e "${BLUE}Enabling NVIDIA sleep services...${NC}"
sudo systemctl enable nvidia-suspend nvidia-hibernate nvidia-resume
