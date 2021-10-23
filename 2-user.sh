#!/usr/bin/env bash
#-------------------------------------------------------------------------
#   █████╗ ██████╗  ██████╗██╗  ██╗████████╗██╗████████╗██╗   ██╗███████╗
#  ██╔══██╗██╔══██╗██╔════╝██║  ██║╚══██╔══╝██║╚══██╔══╝██║   ██║██╔════╝
#  ███████║██████╔╝██║     ███████║   ██║   ██║   ██║   ██║   ██║███████╗
#  ██╔══██║██╔══██╗██║     ██╔══██║   ██║   ██║   ██║   ██║   ██║╚════██║
#  ██║  ██║██║  ██║╚██████╗██║  ██║   ██║   ██║   ██║   ╚██████╔╝███████║
#  ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝   ╚═╝    ╚═════╝ ╚══════╝
#-------------------------------------------------------------------------

echo -e "\nINSTALLING AUR SOFTWARE\n"
# You can solve users running this script as root with this and then doing the same for the next for statement. However I will leave this up to you.

echo "CLONING: YAY"
cd ~
git clone "https://aur.archlinux.org/yay.git"
cd ${HOME}/yay
makepkg -si --noconfirm
cd ~
touch "$HOME/.cache/zshhistory"
git clone "https://github.com/ChrisTitusTech/zsh"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $HOME/powerlevel10k
ln -s "$HOME/zsh/.zshrc" $HOME/.zshrc

PKGS=(
'anydesk-bin'
'autojump'
'ausweisapp2'
'awesome-terminal-fonts'
'brave-bin' # Brave Browser
'ckb-next-git'
'cups-bjnp'
'dxvk-bin' # DXVK DirectX to Vulcan
'etcher-bin'
'github-desktop-bin' # Github Desktop sync
# 'lightly-git'
'mangohud' # Gaming FPS Counter
'mangohud-common'
'minecraft-launcher'
'intellij-idea-ultimate-edition'
'intellij-idea-ultimate-edition-jre'
'nerd-fonts-fira-code'
'noto-fonts-emoji'
'ocs-url' # install packages from websites
'phpstorm'
'phpstorm-jre'
'pycharm-professional'
'rambox-bin'
'rtl88x2bu-dkms-git'
'sddm-nordic-theme-git'
'timeshift'
'ttf-droid'
'ttf-hack'
'ttf-meslo' # Nerdfont package
'ttf-roboto'
'ttf-ms-fonts'
'typora'
'ventoy-bin'
'zenmap'
'zoom' # video conferences
#'snapper-gui-git'
#'snap-pac'
)

for PKG in "${PKGS[@]}"; do
    yay -S --noconfirm $PKG
done

export PATH=$PATH:~/.local/bin
cp -r $HOME/ArchDave/dotfiles/* $HOME/.config/
pip install konsave
konsave -i $HOME/ArchDave/kde.knsv
sleep 1
konsave -a kde

echo -e "\nDone!\n"
exit
