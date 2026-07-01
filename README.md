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

## Shortcuts

Vim leader is **space**. Tmux prefix is **Ctrl-a**.

### Vim - files & explorer
| key            | action |
|----------------|--------|
| `<leader>e`    | toggle tree sidebar (netrw) |
| `<leader>E`    | open sidebar at current file's directory |
| `-`            | (in any buffer) jump into netrw at current file's dir |
| `v` / `Ctrl-v` | (in netrw) open file under cursor in a vertical split |
| `o`            | (in netrw) open under cursor in a horizontal split |
| `%` / `d`      | (in netrw) new file / new directory |
| `R` / `D`      | (in netrw) rename / delete |
| `<leader>ff`   | fuzzy find files (fzf) |
| `<leader>fg`   | fuzzy find git-tracked files |
| `<leader>fr`   | ripgrep search |
| `<leader>fb`   | fuzzy find open buffers |
| `<leader>fc`   | fuzzy find files under `$CMSSW_BASE/src` |
| `<leader>fC`   | ripgrep scoped to `$CMSSW_BASE/src` (.cc/.h/.py) |
| `<leader>cf`   | open CMSSW-relative path/header under cursor |
| `<leader>cv`   | same, in a vertical split |
| `gf`           | open file under cursor (path-aware, incl. CMSSW paths) |

### Vim - windows, buffers, terminal
| key                | action |
|--------------------|--------|
| `<leader>a/s/d/w`  | move to window left/down/right/up |
| `<leader>=`        | equalize window sizes |
| `<leader>tt`       | toggle a terminal split (open / hide / reopen same session) |
| `Esc` (in terminal)| back to normal mode |
| `]b` / `[b`        | next / previous buffer |
| `<leader>bd`       | delete buffer |
| `<leader>x`        | save |
| `<leader>es`       | quit window |

### Vim - code (LSP: clangd for C++, pyright for Python)
| key          | action |
|--------------|--------|
| `gd`         | go to definition |
| `gr`         | references |
| `gi`         | implementation |
| `K`          | hover docs |
| `<leader>rn` | rename symbol |
| `<leader>ca` | code action |
| `]e` / `[e`  | next / previous diagnostic |
| `Tab`/`S-Tab`| cycle completion popup |
| `Ctrl-Space` | force completion popup |

First-time per machine: open a `.cc`/`.py` file and run `:LspInstallServer`; for C++
also run `scram build -j4 compile_commands.json` so clangd sees your flags.

### Vim - git (fugitive + gitgutter)
| key          | action |
|--------------|--------|
| `<leader>gs` | `:Git` status |
| `<leader>gd` | diff split |
| `<leader>gb` | blame |
| `<leader>gc` | commit |
| `<leader>gp` / `gP` | push / pull |
| `]h` / `[h`  | next / previous git hunk |
| `<leader>hs` / `hu` | stage / undo hunk |

### Tmux
| key                  | action |
|----------------------|--------|
| `prefix -` / `\|`     | split horizontal / vertical (in current dir) |
| `prefix c`           | new window (in current dir) |
| `prefix m`           | zoom/unzoom pane |
| `Ctrl-h/j/k/l`       | move between panes - forwarded into vim splits automatically |
| `Alt-h` / `Alt-l`    | previous / next window |
| `prefix S`           | switch session |
| `prefix N`           | new named session |
| `prefix M-1` / `M-2` | preset layouts (editor+terminal, side-by-side / stacked) |
| `Ctrl-double-click`  | resolve and open a file/path under the mouse in a new split |
| copy-mode `o`        | open the selected file:line in a new split |
| `prefix I`           | install tmux plugins (TPM) |
