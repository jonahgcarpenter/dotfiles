# Dotfiles

![arch_btw](https://github.com/user-attachments/assets/d5137b2a-0cbd-4f40-beb8-9c685d9319c6)

## Check for subdirectory README's when necessary

### Packages

sudo pacman -S btop --noconfirm --needed

sudo pacman -S waybar --noconfirm --needed

sudo pacman -S rofi --noconfirm --needed

sudo pacman -S solaar --noconfirm --needed

sudo pacman -S liquidctl --noconfirm --needed

sudo pacman -S discord --noconfirm --needed

sudo pacman -S kubectl --noconfirm --needed

sudo pacman -S hyprpaper --noconfirm --needed

sudo pacman -S pamixer --noconfirm --needed

sudo pacman -S ly --noconfirm --needed

sudo pacman -S nvim --noconfirm --needed

sudo pacman -S tmux --noconfirm --needed

sudo pacman -S zsh --noconfirm --needed

sudo pacman -S pavucontrol --noconfirm --needed

### Oh My Zsh

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# YAY

## Install YAY

sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

### Packages

yay -S spotify

yay -S google-chrome

yay -S flameshot-git
