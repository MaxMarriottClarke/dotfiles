" ==============================================================================
"  ~/.vimrc
" ==============================================================================


" -- Leader --------------------------------------------------------------------
let mapleader = " "


" ==============================================================================
"  PLUGINS  (vim-plug)
" ==============================================================================

call plug#begin()

" -- Editor behaviour ----------------------------------------------------------
Plug 'RRethy/vim-illuminate'          " highlight other uses of word under cursor
Plug 'tpope/vim-commentary'           " gc / gcc to comment lines
Plug 'tpope/vim-surround'             " cs\"' to change surrounding quotes etc.
Plug 'jiangmiao/auto-pairs'           " auto-close brackets, quotes

" -- File navigation -----------------------------------------------------------
Plug 'preservim/nerdtree'             " tree explorer sidebar (see FILE EXPLORER)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" -- Git -----------------------------------------------------------------------
Plug 'tpope/vim-fugitive'             " full git workflow inside vim
Plug 'airblade/vim-gitgutter'         " per-line diff signs + hunk staging

" -- Completion & LSP (works on any vim 8+, no version requirement) -----------
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'          " auto-installs language servers (clangd, pyright)
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'preservim/vim-markdown'

call plug#end()

" Auto-pairs: disable space padding inside brackets (causes the dot-on-space bug)
let g:AutoPairsMapSpace = 0
let g:AutoPairsMultilineClose = 0


" ==============================================================================
"  CORE SETTINGS
" ==============================================================================

" ==============================================================================
"  MARKDOWN
" ==============================================================================

let g:vim_markdown_folding_disabled = 1       " folding can be disorienting, off by default
let g:vim_markdown_conceal = 0                " set to 1 if you want live rendering of **bold** etc.
let g:vim_markdown_conceal_code_blocks = 0
let g:vim_markdown_new_list_item_indent = 0   " don't over-indent new list items
let g:vim_markdown_auto_insert_bullets = 1    " the key feature: auto-continue lists
let g:vim_markdown_frontmatter = 1            " highlight YAML front matter (useful for Hugo)

" Tab/S-Tab to indent/unindent list items in insert mode
autocmd FileType markdown inoremap <buffer> <Tab>   <Esc>>>A
autocmd FileType markdown inoremap <buffer> <S-Tab> <Esc><<A

" And in normal mode for consistency
autocmd FileType markdown nnoremap <buffer> <Tab>   >>
autocmd FileType markdown nnoremap <buffer> <S-Tab> <<

" -- Filetype & syntax ---------------------------------------------------------
filetype on
filetype plugin on
filetype indent on
syntax on

" -- Display -------------------------------------------------------------------
set relativenumber
set number                  " show absolute number on current line
set cursorline
set scrolloff=8             " keep 8 lines above/below cursor when scrolling
set signcolumn=yes          " always show gutter (no layout jump when signs appear)
set nowrap
set colorcolumn=100         " soft column guide at 100 chars (common in CMSSW)
set showmatch               " briefly jump to matching bracket

" -- Indentation ---------------------------------------------------------------
set shiftwidth=4
set tabstop=4
set expandtab
set autoindent
set smartindent

" -- Paste fix ----------------------------------------------------------------
" F2 toggles paste mode - stops autoindent cascading when pasting from outside
set pastetoggle=<F2>

" -- Search --------------------------------------------------------------------
set incsearch
set hlsearch
set ignorecase
set smartcase               " case-sensitive only if query has uppercase

" -- Buffers & files -----------------------------------------------------------
set hidden                  " switch buffers without saving
set nobackup
set nowritebackup
set noswapfile
set autoread                " reload file if changed outside vim

" -- Clipboard -----------------------------------------------------------------
set clipboard=unnamedplus

" -- Splits open naturally -----------------------------------------------------
set splitbelow
set splitright

" -- Auto-equalize split sizes --------------------------------------------------
" Re-equalize on every new window/resize so splits stay evenly sized instead
" of drifting odd as panes open and close. winfixwidth (NERDTree's sidebar, set
" automatically) and winfixheight (terminal toggle, set below) stay exempt.
augroup auto_equalize_splits
    autocmd!
    autocmd VimResized,WinNew * wincmd =
augroup END

" -- Performance ---------------------------------------------------------------
set lazyredraw
set ttyfast
set updatetime=300          " faster sign updates (gitgutter, lsp)

" -- Command line completion ---------------------------------------------------
set wildmenu
set wildmode=list:longest,full
set wildignore+=*.o,*.so,*.pyc,*/.git/*,*/build/*,*/tmp/*



" ==============================================================================
"  COLOURS  -  plain built-in scheme, black background, neon cyan accent
"
"  Palette (matches Alacritty + tmux + bashrc so every surface agrees):
"    black  ctermbg=black / 234   background & subtle panels
"    grey   239 / 245             structure: line numbers, splits, dim text
"    cyan   51                    the ONE accent - cursor line, selection,
"                                  search, current-window/identity markers
"    red 203 / green 114 / yellow 179   functional only (errors/added/warn)
"  Left as plain built-in highlighting (no colorscheme plugin, no
"  truecolour) - just pinning every group that otherwise falls back to a
"  mismatched default.
"  (lx04 machine - main branch/lxplus keeps the black+pink scheme)
" ==============================================================================

set background=dark
colorscheme default

" -- Core surfaces --------------------------------------------------------------
hi Normal      ctermbg=black ctermfg=253
hi NonText     ctermbg=black ctermfg=239        " ~ at end of buffer, no longer stark white
hi EndOfBuffer ctermbg=black ctermfg=239
hi ColorColumn ctermbg=234                       " barely-there dark grey guide at colorcolumn
hi CursorLine  cterm=none ctermbg=234
hi VertSplit   ctermbg=black ctermfg=239
hi WinSeparator ctermbg=black ctermfg=239

" -- Gutter (this is what was showing as a stray white-ish column) --------------
hi SignColumn    ctermbg=black
hi LineNr        ctermbg=black ctermfg=239
hi CursorLineNr  ctermbg=234   ctermfg=51 cterm=bold   " cyan - marks your line

" -- Selection / search - mirrors Alacritty's cyan selection --------------------
hi Visual   ctermbg=239 ctermfg=253
hi Search   ctermbg=51 ctermfg=black
hi IncSearch ctermbg=51 ctermfg=black
hi MatchParen ctermbg=239 ctermfg=51 cterm=bold

" -- Popup / completion menu -----------------------------------------------------
hi Pmenu     ctermbg=234 ctermfg=253
hi PmenuSel  ctermbg=51 ctermfg=black
hi PmenuSbar ctermbg=234
hi PmenuThumb ctermbg=239

" -- Misc built-ins ---------------------------------------------------------------
hi Comment   ctermfg=239
hi Special   ctermfg=239          " quiet grey instead of a loud default highlight
hi Directory ctermfg=51 cterm=bold
hi Question  ctermfg=51
hi StatusLine   ctermbg=234 ctermfg=253 cterm=none
hi StatusLineNC ctermbg=234 ctermfg=239 cterm=none

" -- Diff / gitgutter - keep functional colour, but from the shared palette ------
hi DiffAdd    ctermbg=234 ctermfg=114
hi DiffChange ctermbg=234 ctermfg=179
hi DiffDelete ctermbg=234 ctermfg=203
hi DiffText   ctermbg=234 ctermfg=51
hi GitGutterAdd          ctermbg=black ctermfg=114
hi GitGutterChange       ctermbg=black ctermfg=179
hi GitGutterDelete       ctermbg=black ctermfg=203
hi GitGutterChangeDelete ctermbg=black ctermfg=179

" -- LSP diagnostics - same functional colours as gitgutter/git diff -------------
hi LspErrorHighlight       ctermfg=203
hi LspWarningHighlight     ctermfg=179
hi LspInformationHighlight ctermfg=239
hi LspHintHighlight        ctermfg=239
hi LspErrorText            ctermfg=203
hi LspWarningText          ctermfg=179

" Thin bar cursor in every mode (Vim's default block in normal mode
" overrides the terminal's own cursor style via DECSCUSR) - matches the
" thin-line beam cursor set in the Alacritty config.
set guicursor=a:ver25-blinkon0


" ==============================================================================
"  KEYMAPS
" ==============================================================================

" -- Window navigation ---------------------------------------------------------
noremap <leader>d <C-w>l
noremap <leader>a <C-w>h
noremap <leader>s <C-w>j
noremap <leader>w <C-w>k

" -- Window resize -------------------------------------------------------------
noremap <leader>= <C-w>=
noremap <leader>+ <C-w>5+
noremap <leader>- <C-w>5-
noremap <leader>> <C-w>5>
noremap <leader>< <C-w>5<

" -- Buffer navigation ---------------------------------------------------------
nnoremap ]b :bnext<CR>
nnoremap [b :bprev<CR>
nnoremap <leader>bd :bdelete<CR>
nnoremap <leader>ba :bufdo bd<CR>

" -- Quickfix / error list -----------------------------------------------------
nnoremap ]q :cnext<CR>
nnoremap [q :cprev<CR>
nnoremap <leader>qo :copen<CR>
nnoremap <leader>qc :cclose<CR>

" -- Indentation (keep visual selection after indent) --------------------------
noremap > >>
noremap < <<
vnoremap > >gv
vnoremap < <gv

" -- Clear search highlight ----------------------------------------------------
nnoremap <leader>/ :nohlsearch<CR>

" -- Close ---------------------------------------------------------------------
noremap  <leader>es :q<CR>
nnoremap <leader>eq :bd<CR>

" -- Save ----------------------------------------------------------------------
nnoremap <leader>x :w<CR>


" ==============================================================================
"  TERMINAL  (vim 8.1+ native :terminal)
" ==============================================================================
"
"  <leader>tt  - toggle a terminal in a split at the bottom: opens it, and if
"                already open, hides it (the shell/process keeps running -
"                pressing <leader>tt again brings back the same session)
"  Esc         - exit terminal insert mode back to normal mode (then :close
"                or <leader>tt to hide/kill it)
"  <leader>w/d/a - navigate out of the terminal pane like any other window

function! s:ToggleTerm() abort
    if exists('t:term_bufnr') && bufexists(t:term_bufnr)
        let winid = bufwinid(t:term_bufnr)
        if winid != -1
            call win_gotoid(winid)
            close
        else
            execute 'below sbuffer ' . t:term_bufnr
            resize 16
            setlocal winfixheight
            startinsert
        endif
    else
        below terminal
        let t:term_bufnr = bufnr('%')
        resize 16
        setlocal winfixheight
    endif
endfunction

nnoremap <silent> <leader>tt :call <SID>ToggleTerm()<CR>
tnoremap <silent> <leader>tt <C-w>:call <SID>ToggleTerm()<CR>

tnoremap <Esc>      <C-w>N
tnoremap <leader>w  <C-w>k
tnoremap <leader>d  <C-w>l
tnoremap <leader>a  <C-w>h


" ==============================================================================
"  FILE EXPLORER  (NERDTree - replaces netrw; fern.vim needs Vim 8.2.5136+,
"  this box only has 8.2.2637, so it can't load)
" ==============================================================================
"
"  <leader>e   toggle a tree-style sidebar explorer, rooted at cwd
"  <leader>E   toggle the sidebar rooted at the current file's directory
"
"  Inside the NERDTree window:
"    o / <CR>   open under cursor in the main pane, in place (no split)
"    i          open under cursor, horizontal split, main pane
"    s          open under cursor, vertical split, main pane
"    t          open in a new tab
"    m          add/move/delete/copy menu for the node under cursor
"    r / R      refresh directory / refresh the whole tree
"    I          toggle hidden files
"    q          close the tree window
"    ?          toggle the quick-help cheatsheet
"
"  NERDTree's i/s splits already jump to the previously-used window before
"  splitting, so opening a file lands in the main pane instead of splitting
"  the tree itself - the exact problem netrw had.

let g:NERDTreeShowHidden = 1                       " show dotfiles by default - this is a dotfiles repo
let g:NERDTreeWinSize    = 30                       " sidebar width in columns
let g:NERDTreeMinimalUI  = 1                        " no 'Press ? for help' banner - less clutter
let g:NERDTreeQuitOnOpen = 0                        " keep the tree open after opening a file

nnoremap <leader>e :NERDTreeToggle<CR>
nnoremap <leader>E :NERDTreeToggle %:p:h<CR>

" Strip the global number/colorcolumn/cursorline from the tree - they don't
" apply to a file tree (winfixwidth is already set automatically by NERDTree).
autocmd FileType nerdtree setlocal nonumber norelativenumber nocursorline colorcolumn=


" ==============================================================================
"  FZF
" ==============================================================================

" Floating popup centred in the screen
let g:fzf_layout = { 'down': '40%' }



" -- Mappings ------------------------------------------------------------------
" ff=files, fg=git files, fr=ripgrep, fb=buffers, fh=history, fl=lines, fm=marks
nnoremap <leader>ff :Files<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fr :Rg<CR>
nnoremap <leader>fb :Buffers<CR>
nnoremap <leader>fh :History<CR>
nnoremap <leader>fl :BLines<CR>
nnoremap <leader>fm :Marks<CR>

" -- CMSSW-scoped commands -----------------------------------------------------
" <leader>fc - fuzzy find files under $CMSSW_BASE/src
command! CmsFiles call fzf#vim#files($CMSSW_BASE . '/src', <bang>0)
nnoremap <leader>fc :CmsFiles<CR>

" <leader>fC - ripgrep scoped to $CMSSW_BASE/src (.cc .h .py only)
command! -nargs=* CmsRg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case --glob "*.cc" --glob "*.h" --glob "*.py" ' . shellescape(<q-args>) . ' ' . $CMSSW_BASE . '/src', 1, <bang>0)
nnoremap <leader>fC :CmsRg<CR>


" ==============================================================================
"  GIT  - fugitive + gitgutter
" ==============================================================================
"
"  Fugitive quick reference (inside :Git status press g? for full help):
"    s        stage file or hunk under cursor
"    u        unstage
"    =        toggle inline diff for file
"    dd       open diff split
"    cc       open commit message buffer
"    X        discard change
"    q        close status window
"
"  Merge conflict 3-way diff (<leader>gm):
"    <leader>gh   take the LEFT  side (ours)
"    <leader>gl   take the RIGHT side (theirs)
"    ]c / [c      jump to next / prev conflict marker

" -- Fugitive mappings ---------------------------------------------------------
nnoremap <leader>gs :Git<CR>
nnoremap <leader>gd :Gdiffsplit<CR>
nnoremap <leader>gb :Git blame<CR>
nnoremap <leader>gl :0Gclog<CR>
nnoremap <leader>gL :Git log --oneline --graph --all<CR>
nnoremap <leader>lg :below terminal lazygit<CR>
nnoremap <leader>gp :Git push<CR>
nnoremap <leader>gP :Git pull<CR>
nnoremap <leader>gc :Git commit<CR>
nnoremap <leader>gw :Gwrite<CR>

" -- Merge conflict resolution -------------------------------------------------
nnoremap <leader>gm :Gdiffsplit!<CR>
nnoremap <leader>gh :diffget //2<CR>
nnoremap <leader>gr :diffget //3<CR>

" -- GitGutter -----------------------------------------------------------------
let g:gitgutter_sign_added              = '+'
let g:gitgutter_sign_modified           = '~'
let g:gitgutter_sign_removed            = '-'
let g:gitgutter_sign_removed_first_line = '-'
let g:gitgutter_sign_modified_removed   = '~'

" Navigate hunks
nnoremap ]h :GitGutterNextHunk<CR>
nnoremap [h :GitGutterPrevHunk<CR>

" Stage / undo / preview individual hunks without opening :Git status
nnoremap <leader>hs :GitGutterStageHunk<CR>
nnoremap <leader>hu :GitGutterUndoHunk<CR>
nnoremap <leader>hp :GitGutterPreviewHunk<CR>

" Toggle gutter
nnoremap <leader>hg :GitGutterToggle<CR>


" ==============================================================================
"  VIM-LSP  (completion + LSP - works on vim 8+, no version requirement)
" ==============================================================================
"
"  First-time setup:
"    1. Open any .cc or .py file and run :LspInstallServer
"       vim-lsp-settings will auto-detect and install clangd / pylsp
"    2. For C++, generate compile_commands.json so clangd knows your flags:
"         scram build -j4 compile_commands.json
"
"  Tab to cycle completion, S-Tab to go back, CR to confirm

imap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
imap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
imap <expr> <CR>    pumvisible() ? asyncomplete#close_popup() : "\<CR>"

" Trigger manually with Ctrl+Space instead of auto-popup
imap <C-Space> <Plug>(asyncomplete_force_refresh)

" Show completion menu automatically
let g:asyncomplete_auto_popup = 0     " only trigger manually, stops popup on space
let g:asyncomplete_popup_delay = 0

" Quieter completion (no preview window)
set completeopt=menuone,noinsert,noselect

" -- Navigation ----------------------------------------------------------------
nmap <silent> gd :LspDefinition<CR>
nmap <silent> gr :LspReferences<CR>
nmap <silent> gi :LspImplementation<CR>
nmap <silent> gt :LspTypeDefinition<CR>

" -- Hover docs ----------------------------------------------------------------
nnoremap <silent> K :LspHover<CR>

" -- Rename symbol across files ------------------------------------------------
nnoremap <leader>rn :LspRename<CR>

" -- Diagnostics ---------------------------------------------------------------
nmap <silent> ]e :LspNextError<CR>
nmap <silent> [e :LspPreviousError<CR>
nnoremap <leader>ce :LspDocumentDiagnostics<CR>

" -- Code actions --------------------------------------------------------------
nnoremap <leader>ca :LspCodeAction<CR>

" -- LSP signs in gutter -------------------------------------------------------
let g:lsp_diagnostics_signs_error         = {'text': 'E'}
let g:lsp_diagnostics_signs_warning       = {'text': 'W'}
let g:lsp_diagnostics_signs_hint          = {'text': '*'}
let g:lsp_diagnostics_signs_information   = {'text': '*'}
let g:lsp_diagnostics_virtual_text_enabled = 0   " keep it clean, use ]e/[e
let g:lsp_document_highlight_enabled      = 0    " illuminate handles this


" ==============================================================================
"  CMSSW PATH INTEGRATION
" ==============================================================================

function! s:AddCMSSWPaths()
    let cmssw = $CMSSW_BASE
    if empty(cmssw) | return | endif
    execute 'set path+=' . cmssw . '/src/**'
    execute 'set path+=' . cmssw . '/lib/**'
endfunction
call s:AddCMSSWPaths()

command! CMSSWRefresh call s:AddCMSSWPaths() | echo "CMSSW paths refreshed"

" gf resolves headers; <leader>cf opens CMSSW-relative path under cursor
nnoremap <leader>cf :call OpenCMSSWPath()<CR>
nnoremap <leader>cv :call OpenCMSSWPathSplit()<CR>

function! OpenCMSSWPath()
    let cmssw = $CMSSW_BASE
    let token = expand('<cfile>')
    if filereadable(token) || isdirectory(token)
        execute 'edit ' . fnameescape(token) | return
    endif
    if !empty(cmssw)
        let full = cmssw . '/src/' . token
        if filereadable(full) || isdirectory(full)
            execute 'edit ' . fnameescape(full) | return
        endif
        let hits = globpath(cmssw . '/src', '**/' . fnamemodify(token, ':t'), 0, 1)
        if !empty(hits)
            if len(hits) == 1
                execute 'edit ' . fnameescape(hits[0])
            else
                call setqflist(map(copy(hits), '{"filename": v:val, "lnum": 1}'))
                copen
            endif
            return
        endif
    endif
    echo "Not found: " . token
endfunction

function! OpenCMSSWPathSplit()
    let token = expand('<cfile>')
    let cmssw = $CMSSW_BASE
    if filereadable(token)
        let full = token
    elseif !empty(cmssw) && filereadable(cmssw . '/src/' . token)
        let full = cmssw . '/src/' . token
    else
        let full = ''
    endif
    if empty(full) | echo "Not found: " . token | return | endif
    execute 'vsplit ' . fnameescape(full)
endfunction


" ==============================================================================
"  STATUSLINE  (built-in, no plugin)
" ==============================================================================

set laststatus=2
set statusline=\ %<%f\ %h%m%r                                    " filename, flags
set statusline+=%{exists('*FugitiveHead')\ &&\ FugitiveHead()!=''\ ?\ '\ \ ('.FugitiveHead().')'\ :\ ''}
set statusline+=%=                                               " right-align from here
set statusline+=%y\ %l:%c\ %p%%\                                 " filetype, line:col, %


" ==============================================================================
"  ILLUMINATE
" ==============================================================================

let g:Illuminate_delay = 200
hi IlluminatedWordText  cterm=underline gui=underline
hi IlluminatedWordRead  cterm=underline gui=underline
hi IlluminatedWordWrite cterm=underline gui=underline


" ==============================================================================
"  AUTOCOMMANDS
" ==============================================================================

augroup vimrc_misc
    autocmd!
    " Strip trailing whitespace on save
    autocmd BufWritePre *.cc,*.h,*.cpp,*.py,*.vim,*.cfg :%s/\s\+$//e
    " Return to last cursor position when reopening a file
    autocmd BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
    " Refresh CMSSW paths if CMSSW_BASE changes (e.g. after cmsenv in terminal pane)
    autocmd ShellCmdPost * call s:AddCMSSWPaths()
augroup END

autocmd filetype cpp nnoremap <F5> :w <bar> !./run.sh<CR>
autocmd filetype cpp nnoremap <F7> :w <bar> !./run.sh copy<CR>
autocmd filetype cpp nnoremap <F6> :w <bar> !./run.sh reset<CR>


