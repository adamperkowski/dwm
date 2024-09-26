#! /bin/bash

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'

if command -v sudo &> /dev/null; then
    sudo -v && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    SU=sudo
elif command -v doas &> /dev/null; then
    doas true && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    SU=doas
else
    printf "%b\n" "${RED}Escalation tool is required. Install sudo or doas.${RC}"
fi

printf "%b\n" "${YELLOW}Saving user changes...${RC}"
cd "$DWM_DIR" || { printf "%b\n" "${RED}Failed to change directory to \$DWM_DIR.${RC}"; exit 1; }
timestamp=$(date +%s)
git diff > "/tmp/dwm-$timestamp.diff" > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to save the patch file.${RC}"; exit 1; }
printf "%b\n" "${GREEN}Saved to /tmp/dwm-$timestamp.diff."

printf "%b\n" "${YELLOW}Updating...${RC}"
git fetch origin main
git reset --hard origin/main
git pull --rebase origin main
printf "%b\n" "${GREEN}Repository updated.${RC}"

printf "%b\n" "${YELLOW}Reconfiguring variables...${RC}"
DWM_DIR=$(pwd)
sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"
printf "%b\n" "${GREEN}Variables configured."

printf "%b\n" "${YELLOW}Re-applying user changes...${RC}"
cd "$DWM_DIR"
patch -p1 -N --no-backup-if-mismatch < "/tmp/dwm-$timestamp.diff"
find . -type f -name "*.rej" -exec rm -f {} +
rm -f "/tmp/dwm-$timestamp.diff"
printf "%b\n" "${GREEN}Patch applied.${RC}"

printf "%b\n" "${YELLOW}Installing dwm...${RC}"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dwm.${RC}"; exit 1; }

printf "%b\n" "${GREEN}Done.${RC}"
