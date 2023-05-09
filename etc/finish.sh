ln -sf $XDG_RUNTIME_DIR/{app/com.discordapp.Discord,}/discord-ipc-0 
mkdir -p ~/.config/user-tmpfiles.d
echo 'L %t/discord-ipc-0 - - - - app/com.discordapp.Discord/discord-ipc-0' > ~/.config/user-tmpfiles.d/discord-rpc.conf
systemctl --user enable --now systemd-tmpfiles-setup.service
(
    echo "# Installing Rust"
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    if [ "$?" != 0 ] ; then
            zenity --error \
            --text="Installing Rust Failed"
            exit 1
    fi
    echo "84"
    echo "# Setting up zsh"
    PASSWORD=$(zenity --title="Configure the shell require sudo" --password)
    if [ "$?" != 0 ] ; then
            zenity --error \
            --text="Password Entry Error"
            exit 1
    fi
    echo -e "$PASSWORD\n/usr/bin/zsh" | sudo -S lchsh $USER
    if [ "$?" != 0 ] ; then
            zenity --error \
            --text="Error setting up ZSH"
            exit 1
    fi
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    echo "88"
    echo "# Installing NVM"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
    echo -e '\n\nexport NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> .zshrc
    echo "92"
    echo "# Installing Deno"
    curl -fsSL https://deno.land/x/install/install.sh | sh
    echo -e '
    export DENO_INSTALL="/var/home/phosphorus/.deno"
    export PATH="$DENO_INSTALL/bin:$PATH"
    ' >> .zshrc
    echo "96"
    echo "# Setting up Docker"
    PASSWORD=$(zenity --title="Configure docker require sudo" --password)
    if [ "$?" != 0 ] ; then
            zenity --error \
            --text="Password Entry Error"
            exit 1
    fi
    echo "docker:x:998:$USER" | sudo tee -a /etc/group
    echo "100"
    echo "# Reticulating Final Splines"
) | 
zenity --progress --title="uBlue Desktop Firstboot" --percentage=0 --auto-close --no-cancel --width=300
if [ "$?" != 0 ] ; then
        zenity --error \
        --text="Firstboot Configuration Error"
fi