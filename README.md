# dotfiles

This is my dotfiles repository including **zsh**, **neovim**, and **tmux**.  
It is managed using [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

You need to install GNU Stow first:

```bash
# macOS (Homebrew)
brew install stow

# Debian/Ubuntu
sudo apt install stow

# Clone the repository
git clone https://github.com/dongsin4869/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Example: apply nvim and zsh configs
stow nvim
stow zsh

# Resulting symlinks (examples)
~/.config/nvim   -> ~/dotfiles/.config/nvim
~/.zshrc         -> ~/dotfiles/.zshrc

# Directory structure
.
├── .config
│   ├── gh
│   ├── iterm2
│   ├── nvim
│   ├── tmux
│   └── zsh
├── .fzf.zsh
├── .p10k.zsh
├── .stow-local-ignore
├── .zshrc
└── README.md
```

