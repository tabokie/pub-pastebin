setopt auto_cd
unsetopt nomatch
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib

export PATH=$PATH:/usr/local/go/bin
export GPG_TTY=$(tty)
#alias commit='function _commit { git commit -s -m "$1" && lucky_commit 7; }; _commit '
alias commit='function _commit { git commit -s -m "$1" && git push origin `git branch --show-current` }; _commit '
alias commit2='git commit -s -m '
alias init_repo='git remote set-url origin git@github-tabokie:tabokie/$(basename `git rev-parse --show-toplevel`).git'
alias init_remote='function _init_remote { git remote add $1 git@github-tabokie:$2/$(basename `git rev-parse --show-toplevel`).git }; _init_remote '
alias push='git push origin `git branch --show-current`'
alias glog='git log --oneline --decorate --graph -n 1000'
export PATH=$CARGO_HOME/bin:$PATH
source /opt/rh/devtoolset-8/enable || true

lsd () {
  if [ -z "$1" ]; then
    1="."
  fi
  ls -d "$1"/*/
}

