#!/bin/bash

# customization
PACKAGE_HOME=/data4/tabokie/package

export RUSTUP_HOME=$PACKAGE_HOME/cargo/.rustup
export CARGO_HOME=$PACKAGE_HOME/cargo/.cargo

curl https://sh.rustup.rs -sSf | sh
source ~/.bashrc
cargo install git-delta

