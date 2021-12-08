#!/bin/bash
# Clone and attach the current state of repos to new rocksdb fork.
# usage: ./checkout-rocksdb.sh <user> <branch>
set -ueo pipefail

user=$1
branch=$2
old_branch=""

impl_1() {
    old_branch=`git branch --show-current`
    echo "currently on rust-rocksdb branch" ${old_branch}", continue?"
    read inputs
    git branch -D ${branch}
    git stash && git checkout -b ${branch}
    sed -i -e '/submodule "rocksdb"/,+3d' .gitmodules
    echo "
    [submodule \"rocksdb\"]
        path = librocksdb_sys/rocksdb
        url = https://github.com/"${user}"/rocksdb.git
        branch = ${branch}" >> .gitmodules
    git submodule sync && git submodule update --init --recursive --remote
    git add .gitmodules
    git add librocksdb_sys/rocksdb
    git commit -s -m "switch rocksdb"
    git push -f origin ${branch}
}

exit_1() {
    echo "failed, checking out to" ${old_branch}
    git checkout -- .gitmodules
    git checkout ${old_branch}
}

impl_2() {
    old_branch=`git branch --show-current`
    echo "currently on tikv branch" ${old_branch}", continue?"
    read inputs
    git branch -D ${branch}
    git stash && git checkout -b ${branch}
    sed -i "/tikv\/rust-rocksdb/a branch = \"${branch}\"" components/engine_rocks/Cargo.toml
    sed -i "s/tikv\/rust-rocksdb/${user}\/rust-rocksdb/g" components/engine_rocks/Cargo.toml
    cargo update -p rocksdb
    git add components
    git add Cargo.*
    git commit -s -m "switch rust-rocksdb"
    git push -f origin ${branch}
}

exit_2() {
    echo "failed, checking out to" ${old_branch}
    git checkout -- components
    git checkout -- Cargo.*
    git checkout ${old_branch}
}


cd rust-rocksdb
impl_1 || exit_1

cd ../tikv
impl_2 || exit_2
