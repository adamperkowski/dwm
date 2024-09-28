#! /bin/bash

# TODO $DWM_DIR not set handling

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

if [ -n "$(git diff)" ]; then
    printf "%b" "${BLUE}Do you want to save your changes? (Y/n) ${RC}"
    read -r input
    case $input in
        n|N)
            SAVE_USER_CHANGES=0
            ;;
        *)
            SAVE_USER_CHANGES=1
            ;;
    esac
else
    SAVE_USER_CHANGES=0
fi

if [ "$SAVE_USER_CHANGES" -eq 1 ]; then
    printf "%b\n" "${YELLOW}Saving user changes...${RC}"
    cd "$DWM_DIR" || { printf "%b\n" "${RED}Failed to change directory to \$DWM_DIR.${RC}"; exit 1; }
    git stash > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to stash the changes.${RC}"; exit 1; }
    printf "%b\n" "${GREEN}Changes saved.${RC}"
fi

printf "%b\n" "${YELLOW}Updating...${RC}"
git fetch origin main
git reset --hard origin/main
git pull --rebase origin main
printf "%b\n" "${GREEN}Repository updated.${RC}"

if [ "$SAVE_USER_CHANGES" -eq 1 ]; then
    printf "%b\n" "${YELLOW}Re-applying user changes...${RC}"
    git stash pop > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to pop the stash.${RC}"
    printf "%b\n" "${GREEN}Changes re-applied.${RC}"
fi

printf "%b\n" "${YELLOW}Reconfiguring variables...${RC}"
DWM_DIR=$(pwd)
sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"
printf "%b\n" "${GREEN}Variables configured."

printf "%b\n" "${YELLOW}Installing dwm...${RC}"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dwm.${RC}"; exit 1; }

printf "%b\n" "${GREEN}Done.${RC}"
