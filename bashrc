# ==============================================================================
#  ~/.bashrc
# ==============================================================================

# -- Source global definitions -------------------------------------------------
[ -f /etc/bashrc ] && . /etc/bashrc

# -- Guard: non-interactive shells stop here -----------------------------------
[[ $- != *i* ]] && return


# ==============================================================================
#  ENVIRONMENT
# ==============================================================================

export SCRAM_ARCH=el8_amd64_gcc13
export EDITOR=vim
export VISUAL=vim

# -- PATH (idempotent helper so re-sourcing never duplicates entries) ----------
_path_prepend() { [[ ":$PATH:" != *":$1:"* ]] && export PATH="$1:$PATH"; }

_path_prepend "/afs/cern.ch/user/m/mmarriot/tools/node/bin"

_path_prepend "/afs/cern.ch/cms/caf/scripts"
_path_prepend "/cvmfs/cms.cern.ch/share/x86_64/cms/prmon/v2026022600/bin"
_path_prepend "/cvmfs/cms.cern.ch/common"


# ==============================================================================
#  HISTORY
# ==============================================================================

export HISTSIZE=100000
export HISTFILESIZE=200000
export HISTCONTROL=ignoreboth:erasedups          # no duplicates, skip lines with leading space
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "      # timestamp every entry
export HISTIGNORE="ls:ll:lt:cd:pwd:exit:clear:history"

shopt -s histappend       # append (don't overwrite) across sessions
shopt -s cmdhist          # save multi-line commands as single history entry

# Flush history to disk after every command so tmux sessions share it
PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }history -a; history -n"


# ==============================================================================
#  SHELL OPTIONS
# ==============================================================================

shopt -s checkwinsize   # fix terminal size after each command
shopt -s cdspell        # auto-correct minor cd typos
shopt -s autocd         # bare directory name -> cd into it
shopt -s globstar       # ** recursive glob
shopt -s direxpand      # expand variables in directory completion


# ==============================================================================
#  PROMPT
# ==============================================================================
#
#  Layout (two lines):
#
#  [CMSSW_14_1_0 ok]  ~/src/DataFormats   (git)  main *
#  >
#
#  Colours: uses 256-colour escapes so it works in any xterm-256color terminal.

__prompt_build() {
    local exit_code=$?      # capture FIRST - must be before anything else

    # -- colour palette ---------------------------------------------------------
    # Same as Alacritty/vim/tmux: black bg, one neon cyan accent, grey for structure.
    # Red/green/yellow are kept but used ONLY for genuine status (error/ok/dirty),
    # never for decoration - that's what made the old prompt feel busy.
    local reset='\[\e[0m\]'
    local bold='\[\e[1m\]'
    local red='\[\e[38;5;203m\]'
    local green='\[\e[38;5;114m\]'
    local yellow='\[\e[38;5;179m\]'
    local cyan='\[\e[38;5;51m\]'
    local gray='\[\e[38;5;245m\]'
    local white='\[\e[38;5;253m\]'

    # -- CMSSW zone ------------------------------------------------------------
    local cms_zone=""
    if [[ -n "$CMSSW_BASE" ]]; then
        local release
        release=$(basename "$CMSSW_BASE")
        # Check whether cwd is actually inside this CMSSW tree
        if [[ "$PWD" == "$CMSSW_BASE"* ]]; then
            cms_zone="${gray}[${cyan}${release}${green} ok${gray}]${reset} "
        else
            cms_zone="${gray}[${cyan}${release}${yellow} ~${gray}]${reset} "
        fi
    fi

    # -- path zone (shorten $HOME -> ~, $CMSSW_BASE/src -> @cms) ----------------
    local dir="$PWD"
    dir="${dir/#$HOME/\~}"
    if [[ -n "$CMSSW_BASE" ]]; then
        dir="${dir/#${CMSSW_BASE}\/src/@cms}"
    fi
    local path_zone="${white}${dir}${reset}"

    # -- git zone --------------------------------------------------------------
    local git_zone=""
    if command -v git &>/dev/null; then
        local branch
        branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
            local git_status
            git_status=$(git status --porcelain 2>/dev/null)
            local dirty=""
            [[ -n "$git_status" ]] && dirty="${yellow} *${reset}"
            git_zone="  ${gray}  ${cyan}${branch}${dirty}${reset}"
        fi
    fi

    # -- prompt character (green = ok, red = error) ----------------------------
    local prompt_char
    if [[ $exit_code -eq 0 ]]; then
        prompt_char="${green}>${reset}"
    else
        prompt_char="${red}>${reset} ${red}[x ${exit_code}]${reset}"
    fi

    # -- assemble --------------------------------------------------------------
    local host_zone=""
    if [[ -n "$SSH_CONNECTION" ]]; then
        host_zone="${gray}($(hostname -s)) ${reset}"
    fi
    PS1="${host_zone}${cms_zone}${path_zone}${git_zone}\n${prompt_char} "
}

PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }__prompt_build"


# ==============================================================================
#  CDPATH  (so you can `cd CMSSW_14_1_0` from anywhere)
# ==============================================================================

CDPATH=.:~:/afs/cern.ch/user/m/mmarriot:/eos/user/m/mmarriot






# ==============================================================================
#  FZF
# ==============================================================================

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --no-border
  --info=hidden
  --prompt='> '
  --pointer='>'
  --marker='*'
  --separator=''
  --color=fg:#e6e6e6,bg:-1,hl:#00ffff
  --color=fg+:#ffffff,bg+:#1a1a1a,hl+:#00ffff
  --color=info:#828282,prompt:#00ffff,pointer:#00ffff
  --color=marker:#7ecb8f,spinner:#7ecb8f,header:#828282
"

# Ctrl+T: fuzzy-insert any file path at cursor
export FZF_CTRL_T_COMMAND='find . -type f -not -path "*/\.*" 2>/dev/null'

# Alt+C: fuzzy cd
export FZF_ALT_C_COMMAND='find . -type d -not -path "*/\.*" 2>/dev/null'

# Ctrl+F: fuzzy search under $CMSSW_BASE/src  (insert path at cursor)
fzf-cmssw-widget() {
    if [[ -z "$CMSSW_BASE" ]]; then
        echo "CMSSW_BASE not set"
        return
    fi
    local result
    result=$(find "$CMSSW_BASE/src" -type f 2>/dev/null \
        | sed "s|${CMSSW_BASE}/src/||" \
        | fzf --prompt="cms> " --preview="cat ${CMSSW_BASE}/src/{} 2>/dev/null | head -60")
    if [[ -n "$result" ]]; then
        local inserted="${CMSSW_BASE}/src/${result}"
        READLINE_LINE="${READLINE_LINE:0:$READLINE_POINT}${inserted}${READLINE_LINE:$READLINE_POINT}"
        READLINE_POINT=$(( READLINE_POINT + ${#inserted} ))
    fi
}
bind -x '"\C-f": fzf-cmssw-widget'

# Ctrl+E: fuzzy-open a file in vim directly (works anywhere)
fzf-open-vim() {
    local file
    file=$(find . -type f -not -path "*/\.*" 2>/dev/null | fzf --prompt="open> ")
    [[ -n "$file" ]] && ${EDITOR:-vim} "$file"
}
bind -x '"\C-e": fzf-open-vim'


# ==============================================================================
#  ERROR PATH OPENER
#  Parse the last error output for file:line patterns and open in vim
# ==============================================================================

# Usage: vimatch                 -> pick from all file:line hits in last command
#        vimatch <file:line>     -> open directly
vimatch() {
    if [[ -n "$1" ]]; then
        # Direct: e.g.  vimatch src/Foo/Bar.cc:42
        local file="${1%%:*}"
        local line="${1##*:}"
        # Resolve against CMSSW_BASE if not absolute
        [[ ! -f "$file" && -n "$CMSSW_BASE" ]] && file="${CMSSW_BASE}/src/${file}"
        ${EDITOR:-vim} +"${line}" "$file"
    else
        # Fuzzy: scrape terminal scrollback via fzf
        echo "Paste/pipe output containing file:line references, then Ctrl+D:"
        local pick
        pick=$(cat /dev/stdin \
            | grep -oE '[A-Za-z0-9_./+-]+\.[A-Za-z]+:[0-9]+' \
            | sort -u \
            | fzf --prompt="error> ")
        [[ -n "$pick" ]] && vimatch "$pick"
    fi
}


# ==============================================================================
#  CMSSW HELPERS
# ==============================================================================

# Short alias to reach $CMSSW_BASE/src without typing it
alias @cms='cd "$CMSSW_BASE/src"'

# cdf <pattern>  - fuzzy cd into a package under $CMSSW_BASE/src
cdf() {
    [[ -z "$CMSSW_BASE" ]] && { echo "CMSSW_BASE not set"; return 1; }
    local dir
    dir=$(find "$CMSSW_BASE/src" -mindepth 1 -maxdepth 3 -type d 2>/dev/null \
        | sed "s|${CMSSW_BASE}/src/||" \
        | fzf --query="$1" --prompt="cms-dir> " --select-1 --exit-0)
    [[ -n "$dir" ]] && cd "${CMSSW_BASE}/src/${dir}"
}

# cms-find <name>  - find a file by name anywhere under $CMSSW_BASE/src
cms-find() {
    [[ -z "$CMSSW_BASE" ]] && { echo "CMSSW_BASE not set"; return 1; }
    find "$CMSSW_BASE/src" -name "*${1}*" 2>/dev/null
}

# cms-grep <pattern>  - grep recursively under $CMSSW_BASE/src
cms-grep() {
    [[ -z "$CMSSW_BASE" ]] && { echo "CMSSW_BASE not set"; return 1; }
    grep -r --color=auto --include="*.cc" --include="*.h" --include="*.py" \
        "$@" "$CMSSW_BASE/src"
}

# cms-log  - tail the most recent .log file with ERROR/WARNING highlighting
cms-log() {
    local n=${1:-80}
    local f
    f=$(ls -t ./*.log 2>/dev/null | head -1)
    [[ -z "$f" ]] && f=$(ls -t ~/cms_*.log 2>/dev/null | head -1)
    [[ -z "$f" ]] && { echo "No .log files found"; return 1; }
    echo "==> $f  (last $n lines)"
    tail -n "$n" "$f" \
        | GREP_COLOR='01;31' grep --color=always -E 'ERROR|FATAL|$' \
        | GREP_COLOR='01;33' grep --color=always -E 'WARNING|$'
}

# cmsrel-cd <release>  - cmsrel + cd src + cmsenv in one step
cmsrel-cd() {
    [[ -z "$1" ]] && { echo "Usage: cmsrel-cd <CMSSW_X_Y_Z>"; return 1; }
    cmsrel "$1" && cd "$1/src" && cmsenv
}

# cms-refresh  - re-run cmsenv in current release (useful after re-sourcing bashrc)
cms-refresh() {
    [[ -z "$CMSSW_BASE" ]] && { echo "CMSSW_BASE not set"; return 1; }
    pushd "$CMSSW_BASE/src" > /dev/null && cmsenv && popd > /dev/null
    echo "  cmsenv refreshed for $(basename $CMSSW_BASE)"
}

# lastlog [N]  - show last N lines of most recent .log
lastlog() {
    local n=${1:-50}
    local f
    f=$(ls -t ./*.log 2>/dev/null | head -1)
    [[ -z "$f" ]] && { echo "No .log files found"; return 1; }
    echo "==> $f (last $n lines)"
    tail -n "$n" "$f"
}


# ==============================================================================
#  ALIASES
# ==============================================================================

# -- navigation ----------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias eo='cd /eos/user/m/mmarriot/'
alias no='cd /eos/user/m/mmarriot/Notes/Y1'
alias cf='cd /eos/user/m/mmarriot/cp/comp'

# -- listing -------------------------------------------------------------------
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias lt='ls -lahtr --color=auto'
alias l.='ls -d .* --color=auto'
alias da='cd /data/mmarriot/'
alias mkdir='mkdir -pv'

alias ft='stty sane'
# -- tools ---------------------------------------------------------------------
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias df='df -h'
alias du='du -h'
alias free='free -h'
alias n=vim
alias cmsrun='cmsRun'       # the classic 11pm typo fix

alias s='cd /eos/user/m/mmarriot/Notes/STEAM/'

# -- EOS -----------------------------------------------------------------------
alias eos-ls='eos root://eosuser.cern.ch ls /eos/user/m/mmarriot'

# -- terminal title (updates tmux window name to current dir) ------------------
case "$TERM" in
  xterm*|rxvt*|screen*|tmux*)
    PROMPT_COMMAND="${PROMPT_COMMAND:+$PROMPT_COMMAND; }printf '\033]0;%s\007' \"${PWD/#$HOME/\~}\""
    ;;
esac


# ==============================================================================
#  FUNCTIONS
# ==============================================================================

# Copy files to SWAN projects
TEST() {
    echo "Copying $* -> /eos/user/m/mmarriot/SWAN_projects/"
    cp -r "$@" /eos/user/m/mmarriot/SWAN_projects/
}

# man pages with colour
man() {
    LESS_TERMCAP_mb=$'\e[1;31m' \
    LESS_TERMCAP_md=$'\e[1;36m' \
    LESS_TERMCAP_me=$'\e[0m'    \
    LESS_TERMCAP_se=$'\e[0m'    \
    LESS_TERMCAP_so=$'\e[1;44;33m' \
    LESS_TERMCAP_ue=$'\e[0m'    \
    LESS_TERMCAP_us=$'\e[1;32m' \
    command man "$@"
}

export PATH="$HOME/.local/bin:$PATH"
