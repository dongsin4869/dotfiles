# Setup fzf
# ---------
if [[ ! "$PATH" == */Users/dongsin/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/Users/dongsin/.fzf/bin"
fi

source <(fzf --zsh)
