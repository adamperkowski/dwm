#! /bin/bash

# TODO $DWL_DIR not set handling

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
$SU pacman -S --needed --noconfirm base-devel fastfetch lsd zsh libinput wayland wlroots libxkbcommon wayland-protocols \
    pkg-config libxcb wlroots xorg-xwayland ttf-firacode-nerd pipewire p7zip noto-fonts noto-fonts-cjk noto-fonts-emoji \
    ttf-nerd-fonts-symbols kitty rofi flameshot zsh-syntax-highlighting git zsh-autosuggestions hsetroot zoxide gnupg > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dependencies.${RC}"; exit 1; }
$AUR_HELPER -S --needed --noconfirm lemurs > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install AUR dependencies.${RC}"; exit 1; }
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to install Oh My ZSH. It might be already installed.${RC}"
printf "%b\n" "${GREEN}Dependencies installed.${RC}"

printf "%b\n" "${YELLOW}Linking files...${RC}"
DWL_DIR=$(pwd)

if [ -z "$XDG_CONFIG_HOME" ]; then
    mkdir "$HOME/.config" > /dev/null
    XDG_CONFIG_HOME="$HOME/.config"
fi

ln -sf "$DWL_DIR/extra/zshrc" "$HOME/.zshrc"
mkdir "$XDG_CONFIG_HOME/fastfetch" &> /dev/null
ln -sf "$DWL_DIR/extra/fastfetch.jsonc" "$XDG_CONFIG_HOME/fastfetch/config.jsonc"
mkdir "$XDG_CONFIG_HOME/kitty" &> /dev/null
ln -sf "$DWL_DIR/extra/kitty.conf" "$XDG_CONFIG_HOME/kitty/kitty.conf"
ln -sf "$DWL_DIR/extra/trapd00r-catppuccin.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/trapd00r-catppuccin.zsh-theme"

$SU chmod +x "$DWL_DIR/extra/start-dwl"
$SU mkdir -p /etc/lemurs/wayland > /dev/null
$SU ln -sf "$DWL_DIR/extra/start-dwl" /etc/lemurs/wayland/dwl

sed -i '/^DWL_DIR=/d' "$DWL_DIR/extra/zshrc"
echo "DWL_DIR=$DWL_DIR" >> "$DWL_DIR/extra/zshrc"

# mkdir "$HOME/.images" > /dev/null
# ln -sf "$DWL_DIR/extra/windows-error.jpg" "$HOME/.images/windows-error.jpg"

printf "%b\n" "${GREEN}Files linked.${RC}"

printf "%b\n" "${YELLOW}Setting up dependencies...${RC}"
$SU chsh -s /bin/zsh "$USER" > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to change default shell to ZSH.${RC}"
$SU systemctl disable display-manager.service > /dev/null 2>&1 || printf "%b\n" "${RED}Failed to disable display-manager.service.${RC}"
$SU systemctl enable lemurs.service
printf "%b\n" "${GREEN}Dependencies set up.${RC}"

printf "%b\n" "${YELLOW}Installing dwl...${RC}"
cd "$DWL_DIR/dwl"
rm -f config.h && $SU make install > /dev/null 2>&1 || { printf "%b\n" "${RED}Failed to install dwl.${RC}"; exit 1; }

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
