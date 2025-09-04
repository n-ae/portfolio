#!/bin/bash
sudo apt-get update
sudo apt-get dist-upgrade

# when zscaler enabled
sudo mkdir -p /usr/local/share/ca-certificates/my-custom-ca
sudo cp ../../zscaler-root-ca.crt /usr/local/share/ca-certificates/my-custom-ca/
sudo update-ca-certificates
sudo apt-get install git
sudo apt-get install curl
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source ~/.bashrc

brew install gcc
brew install neovim
