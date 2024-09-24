#! /bin/bash

clear

if command -v sudo &> /dev/null; then
    SU=sudo
elif command -v doas &> /dev/null; then
    SU=doas
else
    echo "Escalation tool is required. Install sudo or doas."
fi

echo "Reconfiguring vars"
DWM_DIR=$(pwd)
sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"

echo "Installing dwm"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install

echo "Done"
