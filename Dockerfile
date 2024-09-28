# Use the latest Ubuntu LTS as the base image
from ubuntu:24.04

# Set environment variables to non-interactive to avoid prompts during package installation
env DEBIAN_FRONTEND=noninteractive

# Use stable neovim package source
run apt-get update && apt-get install -y software-properties-common && add-apt-repository ppa:neovim-ppa/stable

# Update the package list and install necessary packages
run apt-get update && apt-get install -y \
    sudo \
    curl \
    wget \
    git \
    neovim \
    npm \
    fontconfig \
    unzip \
	ripgrep \
	fd-find \
    && rm -rf /var/lib/apt/lists/*

# Install a Nerd Font (e.g., FiraCode Nerd Font)
arg FONT_NAME=JetBrainsMono
arg FONT_VERSION=v3.2.1

run mkdir -p /usr/share/fonts/nerdfonts && \
    wget https://github.com/ryanoasis/nerd-fonts/releases/download/$FONT_VERSION/$FONT_NAME.zip -O /tmp/$FONT_NAME.zip && \
    unzip /tmp/$FONT_NAME.zip -d /usr/share/fonts/nerdfonts/ && \
    fc-cache -fv

# install lazygit from source
run LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
	DOWLOAD_URL="https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
	echo "Downloading lazygit from $DOWLOAD_URL" && \
	curl -Lo lazygit.tar.gz $DOWLOAD_URL && \
	tar xf lazygit.tar.gz lazygit && \
	install lazygit /usr/local/bin

run useradd -ms /bin/bash newuser

# set up a non-root user 
arg username=dev
arg user_uid=1000
arg user_gid=$user_uid

run useradd -m $username 
run usermod -aG sudo $username

# set up neovim configurations (optional, you can add more configurations as needed)
user $username
run mkdir -p /home/$username/.config/nvim
run echo 'set number' >> /home/$username/.config/nvim/init.vim
run echo 'syntax on' >> /home/$username/.config/nvim/init.vim

#clone lazyvim for quick start
run rm -rf ~/.config/nvim  && \
	git clone https://github.com/lazyvim/starter ~/.config/nvim

#extract the roslyn server
# arg RID=linux-x64
# run targetDir="~/.local/share/nvim/roslyn" && \ 
# 	latestVersion=$(curl -s https://api.github.com/repos/Crashdummyy/roslynLanguageServer/releases | grep tag_name | head -1 | cut -d '"' -f4) && \
# 	[[ -z "$latestVersion" ]] && echo "Failed to fetch the latest package information." && exit 1 && \
# 	echo "Latest version: $latestVersion" && \
# 	asset=$(curl -s https://api.github.com/repos/Crashdummyy/roslynLanguageServer/releases | grep "releases/download/$latestVersion" | grep "$RID"| cut -d '"' -f 4) && \
# 	echo "Downloading: $asset" && \
# 	curl -Lo "./roslyn.zip" "$asset" && \
# 	echo "Remove old installation" && \
# 	rm -rf $targetDir/* && \
# 	unzip "./roslyn.zip" -d "$targetDir/" && \
# 	rm "./roslyn.zip"


#keep it running
cmd ["nvim"]

