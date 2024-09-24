#! /bin/bash

clear

if ! command -v pacman &> /dev/null; then
    echo "Automated setup only for Arch Linux"
    exit 1
fi

if command -v sudo &> /dev/null; then
    SU=sudo
elif command -v doas &> /dev/null; then
    SU=doas
else
    echo "Escalation tool is required. Install sudo or doas."
fi

if command -v paru &> /dev/null; then
    AUR_HELPER=paru
elif command -v yay &> /dev/null; then
    AUR_HELPER=yay
else
    echo "Installing paru"
    $SU pacman -S --needed --noconfirm base-devel
    git clone https://aur.archlinux.org/paru-bin.git
    cd paru-bin || return 1
    makepkg -si --noconfirm
    cd ..
    rm -rf paru-bin

    AUR_HELPER=paru
fi

echo "Installing deps"
$SU pacman -S --needed --noconfirm base-devel fastfetch zsh xorg xorg-xinit xorg-xsetroot ttf-firacode-nerd feh pipewire \
    p7zip 
$AUR_HELPER -S --needed --noconfirm picom-ftlabs-git lemurs
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

echo "Linking configs"
DWM_DIR=$(pwd)
ln -sf "$DWM_DIR/extra/zshrc" "$HOME/.zshrc"
mkdir -p "$XDG_CONFIG_HOME/fastfetch"
ln -sf "$DWM_DIR/extra/fastfetch.jsonc" "$XDG_CONFIG_HOME/fastfetch/config.jsonc"
ln -sf "$DWM_DIR/extra/picom.conf" "$XDG_CONFIG_HOME/picom.conf"
ln -sf "$DWM_DIR/extra/trapd00r-catppuccin.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/trapd00r-catppuccin.zsh-theme"

$SU chmod +x "$DWM_DIR/extra/xinitrc"
ln -sf "$DWM_DIR/extra/xinitrc" "$HOME/.xinitrc"
$SU mkdir -p /etc/lemurs/wms
$SU ln -sf "$DWM_DIR/extra/xinitrc" /etc/lemurs/wms/dwm

sed -i '/^DWM_DIR=/d' "$DWM_DIR/extra/zshrc"
echo "DWM_DIR=$DWM_DIR" >> "$DWM_DIR/extra/zshrc"

echo "Setting up deps"
$SU chsh /bin/zsh "$USER"
$SU systemctl disable display-manager.service
$SU systemctl enable lemurs.service

echo "Installing dwm"
cd "$DWM_DIR/dwm"
rm -f config.h && $SU make install

echo "Done"
