SCRIPT_DIR=$(dirname "$(realpath "$0")")

# sudo ln -s $SCRIPT_DIR /dotfiles

stow -t $HOME -d $SCRIPT_DIR alacritty

stow -t $HOME -d $SCRIPT_DIR atuin

stow -t $HOME -d $SCRIPT_DIR flameshot

sudo stow -t /etc/greetd -d $SCRIPT_DIR greetd

stow -t $HOME -d $SCRIPT_DIR hypr

stow -t $HOME -d $SCRIPT_DIR rofi

stow -t $HOME -d $SCRIPT_DIR theming

stow -t $HOME -d $SCRIPT_DIR waybar

stow -t $HOME -d $SCRIPT_DIR zsh
