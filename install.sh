#!/usr/bin/env bash
# ~/dotfiles/install.sh
#
# Symlinks these configs into place and bootstraps the vim/tmux plugin
# managers. Safe to re-run: existing real files get backed up once with a
# .bak suffix, correct symlinks are left alone.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link() {
    local src="$DOTFILES/$1" dest="$HOME/$2"
    if [[ -L "$dest" && "$(readlink "$dest")" == "$src" ]]; then
        return
    fi
    if [[ -e "$dest" || -L "$dest" ]]; then
        echo "backing up existing $dest -> $dest.bak"
        mv "$dest" "$dest.bak"
    fi
    mkdir -p "$(dirname "$dest")"
    ln -s "$src" "$dest"
    echo "linked $dest -> $src"
}

link vimrc        .vimrc
link tmux.conf     .tmux.conf
link bashrc        .bashrc
link gitconfig     .gitconfig
link config/tmux   .config/tmux
link config/git    .config/git

# -- vim-plug --------------------------------------------------------------
if [[ ! -f "$HOME/.vim/autoload/plug.vim" ]]; then
    echo "installing vim-plug"
    curl -fLo "$HOME/.vim/autoload/plug.vim" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# -- tmux plugin manager (TPM) ----------------------------------------------
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
    echo "installing tpm"
    git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi

echo
echo "Done. Next steps:"
echo "  vim  -> :PlugInstall"
echo "  tmux -> prefix + I   (installs tmux plugins)"
