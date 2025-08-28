# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"
export HOMEBREW_NO_AUTO_UPDATE=1

# local
export PATH="$HOME/.local/bin:$PATH"

# editor
export EDITOR="nvim"
export VISUAL="nvim"
set -o vi

# setting encoding language
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"

# history
export HISTFILE=~/.zsh_history
export HISTSIZE=10000
export SAVEHIST=10000

# These options improve history behavior across sessions
setopt SHARE_HISTORY          # Share command history across all open sessions
setopt APPEND_HISTORY         # Append history rather than overwriting it
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks from each command line being added to the history list
setopt HIST_IGNORE_SPACE      # Ignore commands that start with a space (for secret or experimental commands)
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicates first when trimming history

# fzf
[ -f "$HOME/.fzf.zsh" ] && source "$HOME/.fzf.zsh"

export FZF_COMPLETION_TRIGGER='@'
zle     -N             fzf-cd-widget
bindkey -M emacs '^g' fzf-cd-widget
bindkey -M vicmd '^g' fzf-cd-widget
bindkey -M viins '^g' fzf-cd-widget

# node version manager
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# Tmux
# Always work in a tmux session if Tmux is installed
if which tmux >/dev/null 2>&1; then
  # Check if the current environment is suitable for tmux
  if [[ -z "$TMUX" && \
        $TERM != "screen-256color" && \
        $TERM != "screen" && \
        -z "$VSCODE_INJECTION" && \
        -z "$INSIDE_EMACS" && \
        -z "$EMACS" && \
        -z "$VIM" && \
        -z "$INTELLIJ_ENVIRONMENT_READER" ]]; then
    # Try to attach to the default tmux session, or create a new one if it doesn't exist
    tmux attach -t default >/dev/null 2>&1 || tmux new -s default
    exit
  fi
fi

# syntax highlighting
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zoxide
eval "$(zoxide init zsh)"
