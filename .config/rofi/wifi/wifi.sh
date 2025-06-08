#!/bin/bash

# Simple script to toggle Wi-Fi on or off using nmcli.
# This is intended for use with NetworkManager.

# Check the current status of the radio (enabled or disabled)
WIFI_STATUS=$(nmcli radio wifi)

if [ "$WIFI_STATUS" = "enabled" ]; then
    # If Wi-Fi is enabled, turn it off.
    nmcli radio wifi off
else
    # If Wi-Fi is disabled, turn it on.
    nmcli radio wifi on
fi
