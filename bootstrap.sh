#!/bin/bash
set -e

USER_FULLNAME="Ariel de Llano" 
USER_EMAIL="arieldellano@outlook.com"
GIT_DEFAULT_BRANCH="main"

# FUNCTIONS
##############################################################
array_contains () {
    local array="$1[@]"
    local seeking=$2
    local in=1
    for element in "${!array}"; do
        if [[ $element == "$seeking" ]]; then
            in=0
            break
        fi
    done
    return $in
}

# Install dependencies
##############################################################
sudo pacman -S --noconfirm --needed zsh unzip

# Set working environment
##############################################################
# - create temporary folder
TMPDIR=$(mktemp -d -t dbs-XXXXXXXXXX)

# Set git global configuration
##############################################################  
git config --global user.name "$USER_FULLNAME"
git config --global user.email "$USER_EMAIL"
git config --global init.defaultBranch $GIT_DEFAULT_BRANCH

# Install oh-my-zsh and plugins
##############################################################
echo "Installing oh-my-zsh! and plugins..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# _download plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
# - update .zshrc plugins 
plugins=($$(awk '/^plugins=/ {sub(/^.*\(/, ""); sub(/\).*$/, ""); print}' ~/.zshrc))
new_plugins=("zsh-autosuggestions" "zsh-syntax-highlighting")

for plugin in "${new_plugins[@]}"; do
	if ! array_contains plugins $plugin; then
		plugins+=("${plugin}")
	fi
done

plugins=$(printf " %s" "${plugins[@]}")
plugins=${plugins:1}
set -i "s/^plugins=(.*)/plugins=($plugins)/g" ~/.zshrc

# Install fonts
##############################################################
# - ensure fonts folder exist
mkdir -p ~/.local/share/fonts/
# - download Iosevka.zip file
echo "Downloading Iosevka.zip..."
curl -s --show-error --fail -L -o "$TMPDIR/Iosevka.zip" https://github.com/ryanoasis/nerd-fonts/releases/download/v2.3.3/Iosevka.zip
# - unzip
echo "Unzipping..."
unzip -q "$TMPDIR/Iosevka" -d "$TMPDIR/Iosevka"
# - remove the zip file
rm "$TMPDIR/Iosevka.zip"
# - move the font folder to home
mv "$TMPDIR/Iosevka" ~/.local/share/fonts

# Install powerlevel10k
##############################################################
# - download plugin
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# - set zsh theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc 

# Finalize
##############################################################
echo "DONE!"

