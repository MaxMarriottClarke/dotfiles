" ==============================================================================
"  ~/.vimrc
" ==============================================================================


" -- Leader --------------------------------------------------------------------
let mapleader = " "


" ==============================================================================
"  PLUGINS  (vim-plug)
" ==============================================================================

call plug#begin()

" -- Appearance ----------------------------------------------------------------
Plug 'joshdick/onedark.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" -- Editor behaviour ----------------------------------------------------------
Plug 'RRethy/vim-illuminate'          " highlight other uses of word under cursor
Plug 'tpope/vim-commentary'           " gc / gcc to comment lines
Plug 'tpope/vim-surround'             " cs\"' to change surrounding quotes etc.
Plug 'jiangmiao/auto-pairs'           " auto-close brackets, quotes

" -- File navigation -----------------------------------------------------------
Plug 'tpope/vim-vinegar'              " enhances built-in netrw (see FILE EXPLORER)
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

" -- Performance ---------------------------------------------------------------
set lazyredraw
set ttyfast
set updatetime=300          " faster sign updates (gitgutter, lsp)

" -- Command line completion ---------------------------------------------------
set wildmenu
set wildmode=list:longest,full
set wildignore+=*.o,*.so,*.pyc,*/.git/*,*/build/*,*/tmp/*



" ==============================================================================
"  COLOURS
" ==============================================================================

" Enable 24-bit colour if terminal supports it, fall back gracefully
if exists("+termguicolors")
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif
set t_Co=256
silent! colorscheme onedark
hi CursorLineNr guifg=#ffffff
hi ColorColumn  guibg=#2c2f3a


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
            startinsert
        endif
    else
        below terminal
        let t:term_bufnr = bufnr('%')
        resize 16
    endif
endfunction

nnoremap <silent> <leader>tt :call <SID>ToggleTerm()<CR>
tnoremap <silent> <leader>tt <C-w>:call <SID>ToggleTerm()<CR>

tnoremap <Esc>      <C-w>N
tnoremap <leader>w  <C-w>k
tnoremap <leader>d  <C-w>l
tnoremap <leader>a  <C-w>h


" ==============================================================================
"  FILE EXPLORER  (native netrw + vim-vinegar, no heavyweight plugin needed)
" ==============================================================================
"
"  <leader>e   toggle a tree-style sidebar explorer (:Lexplore)
"  <leader>E   open the sidebar rooted at the current file's directory
"  -           (vinegar) jump into netrw at the current file's directory,
"              press - again inside netrw to go up a level
"
"  Inside any netrw/explorer buffer:
"    <CR> / o   open under cursor (o = horizontal split)
"    v / <C-v>  open under cursor in a vertical split
"    %          create a new file
"    d          create a new directory
"    R          rename/move the file under cursor
"    D          delete the file under cursor
"    gh         toggle dotfiles
"    qf         mark file, qF unmark all - then mc/mm/md to copy/move/delete marks

let g:netrw_banner    = 0                          " no banner - faster, less clutter
let g:netrw_liststyle = 3                          " tree view
let g:netrw_winsize   = 25                         " sidebar width (%)
let g:netrw_altv      = 1                          " open vsplits to the right
let g:netrw_keepdir   = 0                          " netrw's cwd follows vim's cwd
let g:netrw_list_hide = '\.pyc$,__pycache__,\.o$,\.so$'

nnoremap <leader>e :Lexplore<CR>
nnoremap <leader>E :Lexplore %:p:h<CR>

" Ctrl-v mirrors netrw's own 'v' (open under cursor in a vertical split)
autocmd FileType netrw nnoremap <buffer> <C-v> v


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
"  AIRLINE
" ==============================================================================

let g:airline_theme                           = 'onedark'
let g:airline_powerline_fonts                 = 0
let g:airline_left_sep                        = ''
let g:airline_right_sep                       = ''
let g:airline_left_alt_sep                    = '|'
let g:airline_right_alt_sep                   = '|'
let g:airline#extensions#tabline#enabled      = 1
let g:airline#extensions#tabline#fnamemod     = ':t'
let g:airline#extensions#lsp#enabled           = 1
let g:airline#extensions#fugitiveline#enabled = 1


" ==============================================================================
"  ILLUMINATE
" ==============================================================================

let g:Illuminate_delay = 200
hi IlluminatedWordText  gui=underline
hi IlluminatedWordRead  gui=underline
hi IlluminatedWordWrite gui=underline


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


