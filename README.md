# dotfiles

This is my dotfiles repository.  
It is managed using [GNU Stow](https://www.gnu.org/software/stow/).

## install and usage

```bash
# macOS (Homebrew)
brew install stow

# Debian/Ubuntu
sudo apt install stow

# Clone the repository
git clone https://github.com/dongsin4869/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Example: apply nvim
stow .config/nvim

# Resulting symlinks (examples)
~/.config/nvim   -> ~/dotfiles/.config/nvim
```
