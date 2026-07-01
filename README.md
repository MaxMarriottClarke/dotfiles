# dotfiles

vim + tmux + bash config, tuned for CMSSW / performance work on CPU & GPU code.

## Layout

| file                  | links to           |
|-----------------------|--------------------|
| `vimrc`               | `~/.vimrc`         |
| `tmux.conf`           | `~/.tmux.conf`     |
| `bashrc`              | `~/.bashrc`        |
| `gitconfig`           | `~/.gitconfig`     |
| `config/tmux/`        | `~/.config/tmux/`  |
| `config/git/`         | `~/.config/git/`   |

Plugin managers (vim-plug, TPM) and the plugins/servers they fetch (`~/.vim/plugged`,
`~/.tmux/plugins`) are *not* stored here - they're bootstrapped by `install.sh` and
managed by the tools themselves, same idea as not committing `node_modules`.

## Install (new machine)

```sh
git clone <this-repo-url> ~/dotfiles
~/dotfiles/install.sh
vim +PlugInstall +qa
tmux new -d && tmux send-keys -t 0 'true' Enter  # then prefix+I inside a real session
```
