#!/bin/bash

echo "Configuring fingerprint services..."
sudo systemctl stop fprintd 2>/dev/null

sudo systemctl enable --now python3-validity

sudo systemctl enable --now open-fprintd

sudo systemctl enable open-fprintd-resume open-fprintd-suspend

echo "----------------------------------------------------"
echo "Ready to enroll fingerprint."
echo "Please swipe/tap your finger on the sensor repeatedly"
echo "until you see 'enroll-completed'."
echo "----------------------------------------------------"
fprintd-enroll

PAM_FILE="/etc/pam.d/ly"
echo "Configuring $PAM_FILE for Password OR Fingerprint..."

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

echo "Setup Complete!"
