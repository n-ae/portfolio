#!/bin/sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/username/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update && brew upgrade

brew install --cask firefox
brew install --cask google-chrome
brew install --cask adguard
brew install --cask protonvpn
brew install --cask discord

brew install --cask visual-studio-code
brew install git
brew install terraform
brew install awscli
brew install cloudflared
brew install jq
brew install docker
brew install colima
brew install --cask postman

curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
. "$HOME/.cargo/env"
# yew:
rustup target add wasm32-unknown-unknown
cargo install --locked trunk
cargo install --locked wasm-bindgen-cli
# yew

# node:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.4/install.sh | bash
nvm install node # "node" is an alias for the latest version
# node

brew install --cask ngrok
brew tap cargo-lambda/cargo-lambda
brew install cargo-lambda
