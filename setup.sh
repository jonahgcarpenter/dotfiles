#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}### Device Selection ###${NC}"
echo "Which device type is this?"
echo "1) Desktop"
echo "2) Laptop"
read -r -p "Enter choice [1-2]: " device_type

scripts_to_run=(
    "scripts/install-yay.sh"
    "scripts/install-packages.sh"
    "scripts/install-dotfiles.sh"
    "scripts/docker-setup.sh"
)

target_dir=""

case $device_type in
    1)
        target_dir="scripts/desktop"
        echo -e "${GREEN}--> Desktop selected.${NC}"
        ;;
    2)
        target_dir="scripts/laptop"
        echo -e "${GREEN}--> Laptop selected.${NC}"
        ;;
    *)
        echo -e "${RED}Invalid selection. Exiting.${NC}"
        exit 1
        ;;
esac

if [ -d "$target_dir" ]; then
    shopt -s nullglob
    specific_scripts=("$target_dir"/*.sh)
    shopt -u nullglob

    if [ ${#specific_scripts[@]} -gt 0 ]; then
        echo -e "${GREEN}--> Found ${#specific_scripts[@]} scripts in $target_dir. Adding them to queue...${NC}"
        scripts_to_run+=("${specific_scripts[@]}")
    else
        echo -e "${YELLOW}--> No scripts found in $target_dir. Proceeding with globals only.${NC}"
    fi
else
    echo -e "${YELLOW}--> Directory $target_dir does not exist. Proceeding with globals only.${NC}"
fi

echo -e "\n${BLUE}### Starting Setup Process ###${NC}"
echo -e "${BLUE}The following scripts will be executed:${NC}"
for s in "${scripts_to_run[@]}"; do
    echo " - $s"
done
echo ""

for script in "${scripts_to_run[@]}"; do
    if [ -f "$script" ]; then
        echo -e "\n${GREEN}--- Running script: $script ---${NC}"
        if bash "$script"; then
            echo -e "${GREEN}--- Finished: $script ---${NC}"
        else
            echo -e "${RED}--- Failed: $script ---${NC}"
        fi
    else
        echo -e "${RED}Error: File not found: $script${NC}"
    fi
done

echo -e "\n${BLUE}### Setup Process Complete! ###${NC}\n"
echo -e "\n${BLUE}### Ensure to reboot to finish setup ###${NC}"
