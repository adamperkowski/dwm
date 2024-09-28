#! /bin/bash

# TODO $DWM_DIR not set handling

RC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
BLUE='\033[34m'

if ! command -v pacman &> /dev/null; then
    printf "%b\n" "${RED}Automated setup only for Arch Linux.${RC}"
    exit 1
fi

if command -v sudo &> /dev/null; then
    sudo -v && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    SU=sudo
elif command -v doas &> /dev/null; then
    doas true && clear || { printf "%b\n" "${RED}Failed to gain elevation.${RC}"; exit 1; }
    SU=doas
else
    printf "%b\n" "${RED}Escalation tool is required. Install sudo or doas.${RC}"
fi

if command -v paru &> /dev/null; then
    AUR_HELPER=paru
elif command -v yay &> /dev/null; then
    AUR_HELPER=yay
else
    printf "%b\n" "${YELLOW}Installing paru...${RC}"
    $SU pacman -S --needed --noconfirm base-devel > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install build dependencies.${RC}"; exit 1; }
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin || return 1
    makepkg -si --noconfirm
    cd ..
    rm -rf paru-bin

    AUR_HELPER=paru
    printf "%b\n" "${GREEN}Paru installed.${RC}"
fi

printf "%b\n" "${YELLOW}Installing dependencies...${RC}"
$SU pacman -S --needed --noconfirm base-devel fastfetch zsh xorg xorg-xinit xorg-xsetroot ttf-firacode-nerd pipewire \
    p7zip noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-nerd-fonts-symbols kitty rofi flameshot zsh-syntax-highlighting git \
    zsh-autosuggestions hsetroot zoxide > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dependencies.${RC}"; exit 1; }
$AUR_HELPER -S --needed --noconfirm picom-ftlabs-git lemurs > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install AUR dependencies.${RC}"; exit 1; }
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to install Oh My ZSH. It might be already installed.${RC}"
printf "%b\n" "${GREEN}Dependencies installed.${RC}"

printf "%b\n" "${YELLOW}Linking files...${RC}"
DWM_DIR=$(pwd)

if [ -z "$XDG_CONFIG_HOME" ]; then
    mkdir "$HOME/.config"
    XDG_CONFIG_HOME="$HOME/.config"
fi

ln -sf "$DWM_DIR/extra/zshrc" "$HOME/.zshrc"
mkdir "$XDG_CONFIG_HOME/fastfetch" > /dev/null
ln -sf "$DWM_DIR/extra/fastfetch.jsonc" "$XDG_CONFIG_HOME/fastfetch/config.jsonc"
mkdir "$XDG_CONFIG_HOME/kitty" > /dev/null
ln -sf "$DWM_DIR/extra/kitty.conf" "$XDG_CONFIG_HOME/kitty/kitty.conf"
ln -sf "$DWM_DIR/extra/picom.conf" "$XDG_CONFIG_HOME/picom.conf"
ln -sf "$DWM_DIR/extra/trapd00r-catppuccin.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/trapd00r-catppuccin.zsh-theme"

$SU chmod +x "$DWM_DIR/extra/xinitrc"
ln -sf "$DWM_DIR/extra/xinitrc" "$HOME/.xinitrc"
$SU mkdir -p /etc/lemurs/wms > /dev/null
$SU ln -sf "$DWM_DIR/extra/xinitrc" /etc/lemurs/wms/dwm

sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"

# mkdir "$HOME/.images" > /dev/null
# ln -sf "$DWM_DIR/extra/windows-error.jpg" "$HOME/.images/windows-error.jpg"

printf "%b\n" "${GREEN}Files linked.${RC}"

printf "%b\n" "${YELLOW}Setting up dependencies...${RC}"
$SU chsh -s /bin/zsh "$USER" > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to change default shell to ZSH.${RC}"
$SU systemctl disable display-manager.service > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to disable display-manager.service.${RC}"
$SU systemctl enable lemurs.service
printf "%b\n" "${GREEN}Dependencies set up.${RC}"

printf "%b\n" "${YELLOW}Installing dwm...${RC}"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dwm.${RC}"; exit 1; }

printf "%b\n" "${GREEN}Done.${RC}"

printf "%b" "${BLUE}Do you want to reboot your system now? (y/N) ${RC}"
read -r input
case $input in
    y|Y)
        $SU reboot
	;;
    *)
        printf "%b\n" "Reboot your system manually."
        exit 0
	;;
esac
