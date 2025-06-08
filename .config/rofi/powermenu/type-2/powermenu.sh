#!/bin/bash

# Define the options for the powermenu
# You can add or remove options here
options="Shutdown\nReboot\nLock\nSuspend\nLogout"

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
        # This uses swaylock, a popular lockscreen for Wayland.
        # If you use a different lockscreen (like hyprlock), change the command here.
        swaylock
        ;;
    "Suspend")
        systemctl suspend
        ;;
    "Logout")
        # This command is specific to Hyprland
        hyprctl dispatch exit
        ;;
    *)
        # This will be executed if the user exits Rofi without making a choice
        # (e.g., by pressing Escape)
        exit 1
        ;;
esac
