#!/bin/bash

# --- Configuration ---
# Define the list of scripts to run in the exact order of execution.
scripts_to_run=(
    "scripts/install-pacman-packages.sh"
    "scripts/install-yay.sh"
    "scripts/install-yay-packages.sh"
    "scripts/install-dotfiles.sh"
    "scripts/docker-setup.sh"
)

# --- Color Codes ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# --- Main Execution Loop ---
echo -e "${BLUE}### Starting Setup Process ###${NC}"
echo -e "${BLUE}Executing ${#scripts_to_run[@]} scripts in a specific order...${NC}"

# Loop through the defined array of scripts
for script in "${scripts_to_run[@]}"; do
    # Check if the script file exists and is executable
    if [ -f "$script" ] && [ -x "$script" ]; then
        echo -e "\n${GREEN}--- Running script: $script ---${NC}"
        
        # Execute the script
        bash "$script"
        
        echo -e "${GREEN}--- Finished script: $script ---${NC}"
    else
        echo -e "\n${RED}Error: Script not found or not executable: $script${NC}"
        echo -e "${YELLOW}Please make sure the script exists and has been made executable (chmod +x $script).${NC}"
        # Exit the master script if any required script is missing
        exit 1
    fi
done

echo -e "\n${BLUE}### Setup Process Complete! ###${NC}\n"
echo -e "\n${BLUE}### Docker Post-Installation Step ###${NC}"
echo -e "${YELLOW}The user '$USER' has been added to the 'docker' group."
echo -e "${YELLOW}For this change to take effect, you must log out and log back in, or restart your computer."
echo -e "${YELLOW}After you do, you will be able to run Docker commands without using 'sudo'.${NC}\n"
echo -e "\n${BLUE}### Welcome to Arch Linux Sir ###${NC}\n"
