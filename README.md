# dotfiles

Personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Contents

| Package | What it configures |
|---|---|
| `bash` | Aliases, prompt (starship), fzf, yazi cd-on-exit, vi mode |
| `nvim` | Neovim (lazy.nvim): LSP, treesitter, telescope, neotest, git |
| `tmux` | C-Space prefix, hjkl panes, top status bar, OSC 52 clipboard |
| `starship` | Prompt format |
| `broot` | Custom verbs (edit, zip, git_diff, backup), skins |
| `yazi` | Minimal: hidden files, dirs first |
| `pi` | [pi coding agent](https://pi.dev): plan/build stage agents, permission policy, extensions |

## Requirements

- `stow`
- For the full setup: `nvim`, `tmux`, `starship`, `fzf`, `eza`, `yazi`, `broot`, `lazygit`

## Install

```sh
git clone https://github.com/pro-dhillxn/dotfiles ~/.dotfiles
cd ~/.dotfiles
./bootstrap.sh
```

`bootstrap.sh` stows all packages into `~` and appends a source line for `~/.config/bash/rc` to `~/.bashrc`.

Uninstall a single package with `stow -D <name>` (e.g. `stow -D tmux`).
