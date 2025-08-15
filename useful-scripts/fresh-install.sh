#!/bin/bash
sudo apt-get update
sudo apt-get dist-upgrade

# when zscaler enabled
sudo mkdir -p /usr/local/share/ca-certificates/my-custom-ca
sudo cp ../../zscaler-root-ca.crt /usr/local/share/ca-certificates/my-custom-ca/
sudo update-ca-certificates
echo 'export CURL_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt' >> ~/.bashrc
source ~/.bashrc
sudo apt-get install git
sudo apt-get install curl
sudo apt install build-essential
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


echo >> ~/.bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
source ~/.bashrc

brew install neovim
brew install redis

brew install --cask sqlcl
pushd /home/linuxbrew/.linuxbrew/Caskroom/sqlcl
# version name agnostic
p=$(dirname $(find . -name sql))
p=${p:1}
cat <<EOF >> ~/.bashrc
export PATH=\${PATH}:/home/linuxbrew/.linuxbrew/Caskroom/sqlcl${p}
EOF
popd

cat <<EOF >> ~/.bashrc
export JAVA_TOOL_OPTIONS="--enable-native-access=ALL-UNNAMED"
EOF

brew install unzip
brew install ripgreg
brew install wget
brew install zig
brew install openjdk
brew install fd
brew install nvm
brew install rust
brew install xclip
brew install make
brew install luarocks

# brew install podman
# sudo apt-get install uidmap
# brew install qemu
# pushd /home/linuxbrew/.linuxbrew/opt/podman/libexec/podman
# wget https://github.com/containers/gvisor-tap-vsock/releases/download/v0.8.6/gvproxy-linux -O gvproxy
# sudo chmod +x gvproxy
# popd

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
cat <<EOF >> ~/.bashrc
mkdir -p ~/.nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
EOF
source ~/.bashrc


wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
rm packages-microsoft-prod.deb
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-8.0
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-6.0
sudo apt-get update && \
  sudo apt-get install -y dotnet-sdk-9.0
