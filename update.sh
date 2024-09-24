#! /bin/bash

clear

if command -v sudo &> /dev/null; then
    SU=sudo
elif command -v doas &> /dev/null; then
    SU=doas
else
    echo "Escalation tool is required. Install sudo or doas."
fi

echo "Saving user changes"
cd "$DWM_DIR"
timestamp=$(date +%s)
git diff > "/tmp/dwm-$timestamp.diff"

echo "Updating"
git fetch origin main
git reset --hard origin/main
git pull --rebase origin main

echo "Reconfiguring vars"
DWM_DIR=$(pwd)
sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"

echo "Re-applying user changes"
cd "$DWM_DIR"
git apply "/tmp/dwm-$timestamp.diff"

echo "Installing dwm"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install

echo "Done"
