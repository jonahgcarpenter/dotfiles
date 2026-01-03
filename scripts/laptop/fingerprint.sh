#!/bin/bash

echo -e "${BLUE}Configuring fingerprint services...${NC}"
sudo systemctl stop fprintd 2>/dev/null

sudo systemctl enable --now python3-validity

sudo systemctl enable --now open-fprintd

sudo systemctl enable open-fprintd-resume open-fprintd-suspend

echo -e "${YELLOW}----------------------------------------------------"
echo "Ready to enroll fingerprint."
echo "Please swipe/tap your finger on the sensor repeatedly"
echo "until you see 'enroll-completed'."
echo -e "----------------------------------------------------${NC}"
fprintd-enroll

PAM_FILE="/etc/pam.d/ly"
echo -e "${BLUE}Configuring $PAM_FILE for Password OR Fingerprint...${NC}"

sudo cp $PAM_FILE "$PAM_FILE.bak"

sudo bash -c "cat > $PAM_FILE" <<EOL
#%PAM-1.0

auth       sufficient   pam_fprintd.so
auth       include      login
-auth      optional     pam_gnome_keyring.so
-auth      optional     pam_kwallet5.so

account    include      login

password   include      login
-password  optional     pam_gnome_keyring.so use_authtok

-session   optional     pam_systemd.so       class=greeter
-session   optional     pam_elogind.so
session    include      login
-session   optional     pam_gnome_keyring.so auto_start
-session   optional     pam_kwallet5.so      auto_start
EOL

echo -e "${GREEN}Setup Complete!${NC}"

HYPRLOCK_PAM="/etc/pam.d/hyprlock"
echo -e "${BLUE}Configuring $HYPRLOCK_PAM for Hyprlock Fingerprint support...${NC}"

if [ -f "$HYPRLOCK_PAM" ]; then
    sudo cp "$HYPRLOCK_PAM" "$HYPRLOCK_PAM.bak"
fi

sudo bash -c "cat > $HYPRLOCK_PAM" <<EOL
#%PAM-1.0

# 1. Try Fingerprint first. 'sufficient' means if this succeeds, unlock immediately.
auth       sufficient   pam_fprintd.so

# 2. If fingerprint fails (or is ignored), fall back to system password.
auth       include      system-auth

# Standard authentication includes
account    include      system-auth
password   include      system-auth
session    include      system-auth
EOL

echo -e "${GREEN}Hyprlock Setup Complete!${NC}"
