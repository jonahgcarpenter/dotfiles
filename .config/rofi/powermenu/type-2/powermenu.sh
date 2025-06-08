#!/bin/bash

# Define the options for the powermenu
options="Shutdown\nReboot\nLock"

# Use Rofi to present the options and capture the user's choice
# The -p flag sets a prompt for the Rofi menu
chosen=$(echo -e "$options" | rofi -dmenu -p "Power Menu")

# Use a case statement to execute a command based on the chosen option
case "$chosen" in
    "Shutdown")
        systemctl poweroff
        ;;
    "Reboot")
        systemctl reboot
        ;;
    "Lock")
        swaylock
        ;;
    *)
        # This will be executed if the user exits Rofi without making a choice
        # (e.g., by pressing Escape)
        exit 1
        ;;
esac
