#!/bin/bash

FOLDER=/root/tabokie/

# install tools
sudo yum update -y
sudo yum install git vim curl wget make gcc cmake -y
sudo yum install centos-release-scl -y
sudo yum install devtoolset-8-gcc devtoolset-8-gcc-c++ -y
sudo yum groupinstall "Development Tools" -y

# github auth
mkdir -p ${FOLDER}/keys
ssh-keygen -t rsa -b 4096 -C "xy.tao@outlook.com" -f ${FOLDER}/keys/github -N ""
eval "$(ssh-agent -s)"
ssh-add ${FOLDER}/keys/github
echo "Host github-tabokie" >> ~/.ssh/config
echo "    HostName github.com" >> ~/.ssh/config
echo "    IdentifyFile ${FOLDER}/keys/github" >> ~/.ssh/config
echo "    IdentifiesOnly yes" >> ~/.ssh/config
ssh -T git@github-tabokie

# install zsh
sudo yum install zsh -y
zsh --version
echo /bin/zsh | sudo lchsh $(whoami)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# load configs
cp ./gitconfig ~/.gitconfig
cp ./zsh_history ~/.zsh_history
cat ./zshrc >> ~/.zshrc
echo "export RUSTUP_HOME=${FOLDER}/packages/cargo/.rustup" >> ~/.zshrc
echo "export CARGO_HOME=${FOLDER}/packages/cargo/.cargo" >> ~/.zshrc
echo ". \"${CARGO_HOME}/env\"" >> ~/.zshrc

# install rust
mkdir -p ${FOLDER}/packages
export RUSTUP_HOME=${FOLDER}/packages/cargo/.rustup
export CARGO_HOME=${FOLDER}/packages/cargo/.cargo
curl https://sh.rustup.rs -sSf | sh
source ~/.bashrc
cargo install git-delta
