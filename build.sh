#!/bin/bash
# run scripts
echo "-- Running scripts defined in recipe.yml --"
buildscripts=$(yq '.scripts[]' < /usr/etc/ublue-recipe.yml)
for script in $(echo -e "$buildscripts"); do \
    echo "Running: ${script}" && \
    /tmp/scripts/$script; \
done
echo "---"

# remove the default firefox (from fedora) in favor of the flatpak
rpm-ostree override remove firefox firefox-langpacks gnome-tour

# echo "-- Adding VS Code signing key --"
# rpm --import https://packages.microsoft.com/keys/microsoft.asc

# echo "-- Adding VS Code repo --"
# sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'


repos=$(yq '.extrarepos[]' < /usr/etc/ublue-recipe.yml)
if [[ -n "$repos" ]]; then
    echo "-- Adding repos defined in recipe.yml --"
    for repo in $(echo -e "$repos"); do \
        wget $repo -P /etc/yum.repos.d/; \
    done
    echo "---"
fi

# Setting up zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Installing NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.3/install.sh | bash
echo -e '\n\nexport NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion' >> .zshrc

# Installing Deno

curl -fsSL https://deno.land/x/install/install.sh | sh
echo -e '
  export DENO_INSTALL="/var/home/phosphorus/.deno"
  export PATH="$DENO_INSTALL/bin:$PATH"
' >> .zshrc

# Setting up Docker
echo "docker:x:998:$USER" | tee -a /etc/group

echo "-- Installing RPMs defined in recipe.yml --"
rpm_packages=$(yq '.rpms[]' < /usr/etc/ublue-recipe.yml)
for pkg in $(echo -e "$rpm_packages"); do \
    echo "Installing: ${pkg}" && \
    rpm-ostree install $pkg; \
done
echo "---"

# install yafti to install flatpaks on first boot, https://github.com/ublue-os/yafti
pip install --prefix=/usr yafti

# add a package group for yafti using the packages defined in recipe.yml
flatpaks=$(yq '.flatpaks[]' < /tmp/ublue-recipe.yml)
# only try to create package group if some flatpaks are defined
if [[ -n "$flatpaks" ]]; then            
    yq -i '.screens.applications.values.groups.Custom.description = "Flatpaks defined by the image maintainer"' /usr/etc/yafti.yml
    yq -i '.screens.applications.values.groups.Custom.default = true' /usr/etc/yafti.yml
    for pkg in $(echo -e "$flatpaks"); do \
        yq -i ".screens.applications.values.groups.Custom.packages += [{\"$pkg\": \"$pkg\"}]" /usr/etc/yafti.yml
    done
fi