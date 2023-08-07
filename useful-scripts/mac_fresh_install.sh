#!/bin/sh

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
(echo; echo 'eval "$(/opt/homebrew/bin/brew shellenv)"') >> /Users/username/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
brew update && brew upgrade

brew install --cask visual-studio-code
brew install --cask google-chrome

brew install git
brew install --cask firefox
brew install rust

brew install terraform
brew install awscli
