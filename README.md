# dotfiles

This is my dotfiles repository.
It is managed using [GNU Stow](https://www.gnu.org/software/stow/).

## configurations

### shell

| path | description |
|---|---|
| `.zshrc` | Main shell config — loads Oh My Zsh, powerlevel10k theme, and conda |
| `.p10k.zsh` | Powerlevel10k theme (8-color lean style, git status, execution time) |
| `.config/zsh/` | Shell environment — homebrew, cargo, locale, vi mode, fzf integration |
| `.tmux.conf` | tmux — `Ctrl+a` prefix, vi keybindings, hjkl pane navigation |

### editor

| path | description |
|---|---|
| `.config/nvim/` | Neovim — lazy.nvim plugin manager, LSP, telescope, treesitter, copilot |
| `.config/vscode/` | VSCode — Dark Modern theme, MesloLGS NF font, black/prettier formatters |

### terminal & tools

| path | description |
|---|---|
| `.config/wezterm/` | WezTerm terminal emulator — custom color scheme, Lua module config |
| `.config/bat/` | bat (cat replacement) — tokyo-night theme |
| `.config/btop/` | btop system monitor — tokyo-night theme, vim keybindings |
| `.config/yazi/` | yazi file manager — layout, preview, and file opener settings |
| `.config/gh/` | GitHub CLI — https protocol, `co` alias (`pr checkout`) |
| `.config/opencode/` | OpenCode AI CLI — keybindings, Google Gemini provider |

### macOS

| path | description |
|---|---|
| `.config/aerospace/` | AeroSpace tiling window manager — per-workspace app mapping, `alt+hjkl` navigation |
| `.config/sketchybar/` | SketchyBar status bar — Lua-scripted menu bar customization |
| `.config/borders/` | JankyBorders — active/inactive window border colors |
| `.config/karabiner/` | Karabiner-Elements — Fn+hjkl→arrows, Ctrl+[→Esc, CapsLock→Ctrl |

### git

| path | description |
|---|---|
| `.gitconfig` | Git — nvim as editor, delta diff (side-by-side), diff3 merge style |

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
