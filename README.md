# Dotfiles

![arch_btw](https://github.com/user-attachments/assets/d5137b2a-0cbd-4f40-beb8-9c685d9319c6)

## [TODO](https://github.com/stars/jonahgcarpenter/lists/dotfiles-todo):

Run install scripts within the /setup-scripts directory

### Oh My Zsh Install

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

### LY Commands

    sudo systemctl disable sddm.service

    sudo systemctl enable ly.service

    sudo cp ~/projects/dotfiles/.config/ly/config.ini /etc/ly/

### NVIM Commands

    cp -r ~/projects/dotfiles/.config/nvim ~/.config/nvim/
