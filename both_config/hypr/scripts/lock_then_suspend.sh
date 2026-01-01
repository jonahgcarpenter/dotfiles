#!/bin/sh

# Start a background subshell that sleeps for 10 minutes (600 seconds)
# and then runs the suspend command.
(sleep 600 && systemctl suspend) &

# Grab the Process ID (PID) of the backgrounded sleep command.
SLEEP_PID=$!

# Lock the screen. The -f flag runs swaylock in the foreground.
# This script will effectively pause on this line until you unlock the screen.
swaylock -f

# Once you unlock the screen, the script continues from here.
# We must now kill the sleep command to prevent it from suspending the system.
# The 'pkill -P $$' command is used to reliably kill the correct sleep
# process started by this script.
pkill -P $$ sleep
