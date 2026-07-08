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
Plug 'justinmk/vim-dirvish'           " the file explorer: netrw-style, - to go up (see FILE EXPLORER)
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" -- Git -----------------------------------------------------------------------
Plug 'tpope/vim-fugitive'             " full git workflow inside vim
Plug 'airblade/vim-gitgutter'         " per-line diff signs + hunk staging

" -- Clipboard (see CLIPBOARD section below) ------------------------------------
Plug 'ojroques/vim-oscyank', {'branch': 'main'}

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

" -- Clipboard -------------------------------------------------------------------
" This box has no +clipboard/+xterm_clipboard (no X server), so
" 'clipboard=unnamedplus' is a silent no-op here. Instead, every yank/delete
" of the unnamed register is pushed to the Mac's system clipboard via an
" OSC52 terminal escape sequence (ojroques/vim-oscyank). OSC52 travels over
" plain SSH - no X11 forwarding needed - and tmux forwards it through
" automatically because 'set-clipboard on' is set in tmux.conf. Needs a
" terminal that honours OSC52 (iTerm2, Alacritty, Kitty, WezTerm all do).
let g:oscyank_silent = 1
if !has('nvim') && !has('clipboard_working')
    let s:oscyank_registers = ['', '+', '*']
    let s:oscyank_operators = ['y', 'd']
    function! s:OscyankOnTextYank(event) abort
        if index(s:oscyank_registers, a:event.regname) != -1
            \ && index(s:oscyank_operators, a:event.operator) != -1
            call OSCYankRegister(a:event.regname)
        endif
    endfunction
    augroup oscyank_auto_copy
        autocmd!
        autocmd TextYankPost * call s:OscyankOnTextYank(v:event)
    augroup END
endif

" -- Splits open naturally -----------------------------------------------------
set splitbelow
set splitright

" -- Auto-equalize split sizes --------------------------------------------------
" Re-equalize on every new window/resize so splits stay evenly sized instead
" of drifting odd as panes open and close. Windows with winfixheight set
" (the terminal toggle below) stay exempt.
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
"  COLOURS  -  plain built-in scheme, black background, pink accent
"
"  Palette (matches Alacritty + tmux + bashrc so every surface agrees):
"    black  ctermbg=black / 234   background & subtle panels
"    grey   239 / 245             structure: line numbers, splits, dim text
"    pink   205                   the ONE accent - cursor line, selection,
"                                  search, current-window/identity markers
"    red 203 / green 114 / yellow 179   functional only (errors/added/warn)
"  Left as plain built-in highlighting (no colorscheme plugin, no
"  truecolour) - just pinning every group that otherwise falls back to a
"  mismatched default.
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
hi CursorLineNr  ctermbg=234   ctermfg=205 cterm=bold   " pink - marks your line

" -- Selection / search - mirrors Alacritty's pink selection --------------------
hi Visual   ctermbg=239 ctermfg=253
hi Search   ctermbg=205 ctermfg=black
hi IncSearch ctermbg=205 ctermfg=black
hi MatchParen ctermbg=239 ctermfg=205 cterm=bold

" -- Popup / completion menu -----------------------------------------------------
hi Pmenu     ctermbg=234 ctermfg=253
hi PmenuSel  ctermbg=205 ctermfg=black
hi PmenuSbar ctermbg=234
hi PmenuThumb ctermbg=239

" -- Misc built-ins ---------------------------------------------------------------
hi Comment   ctermfg=239
hi Special   ctermfg=239          " quiet grey instead of the loud default pink-ish highlight
hi Directory ctermfg=205 cterm=bold
hi Question  ctermfg=205
hi StatusLine   ctermbg=234 ctermfg=253 cterm=none
hi StatusLineNC ctermbg=234 ctermfg=239 cterm=none

" -- Diff / gitgutter - keep functional colour, but from the shared palette ------
hi DiffAdd    ctermbg=234 ctermfg=114
hi DiffChange ctermbg=234 ctermfg=179
hi DiffDelete ctermbg=234 ctermfg=203
hi DiffText   ctermbg=234 ctermfg=205
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
"  FILE EXPLORER  (dirvish - the only browser; netrw is disabled)
" ==============================================================================
"
"  Feels like netrw, none of the jank: a listing is just a normal buffer of
"  real paths, opened full-size in the current window.
"
"    -          from any file: open its directory in this window
"               from a dirvish listing: go up one directory
"    <CR>       open file / descend into dir (in this window)
"    o / a      open in horizontal / vertical split
"    p          preview file under cursor (<C-n>/<C-p> preview next/prev)
"    q          quit browsing, back to the file you came from
"    x          add file to arglist; :Shdo runs a shell cmd over the arglist
"    ~ / cd     jump to home / :lcd to the browsed dir
"    K          file info,  R  refresh,  g?  full help
"    Lines are real paths: y$ yanks the path, /pattern searches names,
"    and :g!/interface/d style filtering works (R restores the listing).
"
"  <leader>e   open the :Scope listing (or cwd listing when no scope is set)

" Directories first, then files (netrw-style), both alphabetical
let g:dirvish_mode = ':sort ,^.*[\/],'

" Dirvish replaces netrw entirely - stop netrw loading at all
let g:loaded_netrwPlugin = 1

nnoremap <leader>e :call <SID>ScopeExplore()<CR>

" Tone down the globals in listings (keep cursorline - it marks the selection)
autocmd FileType dirvish setlocal nonumber norelativenumber colorcolumn=


" ==============================================================================
"  SCOPED WORKSPACE  (:Scope - work on a chosen subset of a huge tree)
" ==============================================================================
"
"  CMSSW is enormous but you only ever touch a few packages at a time.
"  Declare the ones you're working on and the explorer + fuzzy finders
"  narrow to just those - no config files, no session state, just a command:
"
"    :Scope L1Trigger/L1THGCal DataFormats/L1THGCal
"                     set the working set; args tab-complete against both
"                     the cwd and $CMSSW_BASE/src, so plain package names work
"    :Scope           show the current working set
"    :ScopeClear      back to seeing everything
"
"  While a scope is set:
"    <leader>e    dirvish listing of just the scope dirs - your table of
"                 contents: <CR> descends into one, <leader>e comes back
"                 (plain cwd listing when no scope is set)
"    -            inside a scoped dir, going up stops AT the scope: from the
"                 top of a scope dir, - returns to the scope listing instead
"                 of the real (huge) parent directory
"    <leader>ff   fuzzy-find files across the scope dirs only
"    <leader>fr   live grep across the scope dirs only

let g:scope_dirs = get(g:, 'scope_dirs', [])

function! s:ResolveScopeDir(arg) abort
    if isdirectory(expand(a:arg))
        return expand(a:arg)
    endif
    if !empty($CMSSW_BASE) && isdirectory($CMSSW_BASE . '/src/' . a:arg)
        return $CMSSW_BASE . '/src/' . a:arg
    endif
    return ''
endfunction

function! s:SetScope(args) abort
    if empty(a:args)
        echo empty(g:scope_dirs) ? 'No scope set  (:Scope dir1 dir2 ...)'
                                \ : 'Scope: ' . join(g:scope_dirs, '  ')
        return
    endif
    let dirs = []
    for arg in a:args
        let dir = s:ResolveScopeDir(arg)
        if empty(dir)
            echohl WarningMsg
            echomsg 'Not a directory (checked cwd and $CMSSW_BASE/src): ' . arg
            echohl None
        else
            call add(dirs, substitute(dir, '/$', '', ''))
        endif
    endfor
    if empty(dirs) | return | endif      " nothing resolved - keep the old scope
    let g:scope_dirs = dirs
    echo 'Scope: ' . join(g:scope_dirs, '  ')
endfunction

function! s:ScopeComplete(lead, line, pos) abort
    let out = glob(a:lead . '*/', 1, 1)
    if !empty($CMSSW_BASE)
        let src = $CMSSW_BASE . '/src/'
        let out += map(glob(src . a:lead . '*/', 1, 1), 'strpart(v:val, len(src))')
    endif
    return map(out, "substitute(v:val, '/$', '', '')")
endfunction

command! -nargs=* -complete=customlist,s:ScopeComplete Scope call s:SetScope([<f-args>])
command! ScopeClear let g:scope_dirs = [] | echo 'Scope cleared'

" -- Explorer integration --------------------------------------------------------
" A dirvish listing of the scope dirs. This is dirvish's documented "any
" buffer of paths + setf dirvish" pattern (see its README) - every dirvish
" mapping works on it: <CR> descends, o/a split, p previews.
function! s:ScopeExplore() abort
    if empty(g:scope_dirs)
        Dirvish
        return
    endif
    " One reusable scratch buffer. NB: bufhidden must stay 'hide' - dirvish
    " refuses to navigate away from a buffer it would delete.
    let buf = bufnr('^scope://$')
    if buf == -1
        enew
        silent file scope://
        setlocal buftype=nofile bufhidden=hide noswapfile nobuflisted
    else
        execute 'silent buffer' buf
        setlocal modifiable
        silent %delete _
    endif
    call setline(1, map(copy(g:scope_dirs), 'v:val . "/"'))
    setfiletype dirvish
endfunction

" Scope-aware 'go up': the scope listing acts as the virtual parent of each
" scope dir, so - never dumps you into the huge real parent by accident.
function! s:IsScopeRoot(path) abort
    let p = substitute(fnamemodify(a:path, ':p'), '/\+$', '', '')
    for dir in g:scope_dirs
        if substitute(fnamemodify(dir, ':p'), '/\+$', '', '') ==# p
            return 1
        endif
    endfor
    return 0
endfunction

function! s:DirvishUp() abort
    if @% ==# 'scope://'
        echo 'Top of scope  (:Scope to list it, :ScopeClear to browse freely)'
        return
    endif
    if !empty(g:scope_dirs) && s:IsScopeRoot(@%)
        call s:ScopeExplore()
    else
        " what <Plug>(dirvish_up) does: dirvish buffer names end in /, so
        " :h:h of the absolute path is the parent directory
        execute 'Dirvish' fnameescape(fnamemodify(@%, ':p:h:h'))
    endif
endfunction

autocmd FileType dirvish nnoremap <buffer><silent> - :call <SID>DirvishUp()<CR>

" -- fzf integration ---------------------------------------------------------------
function! s:ScopedFiles() abort
    if empty(g:scope_dirs)
        Files
        return
    endif
    let dirs = join(map(copy(g:scope_dirs), 'shellescape(v:val)'))
    let src  = executable('rg') ? 'rg --files ' . dirs
             \ : 'find ' . dirs . ' -type f -not -path ''*/.git/*'''
    call fzf#run(fzf#wrap('scope-files', {'source': src, 'sink': 'e'}))
endfunction

function! s:ScopedRg(query) abort
    let dirs = join(map(copy(g:scope_dirs), 'shellescape(v:val)'))
    call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '
                \ . shellescape(a:query) . ' ' . dirs, 1, 0)
endfunction

command! ScopedFiles call s:ScopedFiles()
command! -nargs=* ScopedRg call s:ScopedRg(<q-args>)


" ==============================================================================
"  FZF
" ==============================================================================

" Floating popup centred in the screen
let g:fzf_layout = { 'down': '40%' }



" -- Mappings ------------------------------------------------------------------
" ff=files, fg=git files, fr=ripgrep, fb=buffers, fh=history, fl=lines, fm=marks
" ff and fr respect :Scope when one is set (identical to :Files/:Rg otherwise)
nnoremap <leader>ff :ScopedFiles<CR>
nnoremap <leader>fg :GFiles<CR>
nnoremap <leader>fr :ScopedRg<CR>
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
    " Release area too, so gf works on headers of packages you haven't checked
    " out. Plain /src, no ** - includes are already Package/Sub/... relative to
    " src, and recursing into a full release on cvmfs would take forever.
    for base in [$CMSSW_FULL_RELEASE_BASE, $CMSSW_RELEASE_BASE]
        if !empty(base) | execute 'set path+=' . base . '/src' | endif
    endfor
endfunction
call s:AddCMSSWPaths()

command! CMSSWRefresh call s:AddCMSSWPaths() | echo "CMSSW paths refreshed"

" gf resolves headers; <leader>cf opens CMSSW-relative path under cursor
nnoremap <leader>cf :call OpenCMSSWPath()<CR>
nnoremap <leader>cv :call OpenCMSSWPathSplit()<CR>

function! OpenCMSSWPath()
    let token = expand('<cfile>')
    if filereadable(token) || isdirectory(token)
        execute 'edit ' . fnameescape(token) | return
    endif
    " Direct hit in the local area first, then the release area
    for base in [$CMSSW_BASE, $CMSSW_FULL_RELEASE_BASE, $CMSSW_RELEASE_BASE]
        if empty(base) | continue | endif
        let full = base . '/src/' . token
        if filereadable(full) || isdirectory(full)
            execute 'edit ' . fnameescape(full) | return
        endif
    endfor
    " Basename search as a fallback - local checkout only (a ** crawl of the
    " full release on cvmfs would hang)
    if !empty($CMSSW_BASE)
        let hits = globpath($CMSSW_BASE . '/src', '**/' . fnamemodify(token, ':t'), 0, 1)
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

" -- CMSSW path completion (insert mode: <C-x><C-u>) -----------------------------
"  Completes CMSSW paths in any file, against $CMSSW_BASE/src AND the full
"  release area - so it works for packages you haven't checked out, with no
"  LSP or compile_commands.json needed. Plain vimscript glob, always works.
"
"    C++ (and everything else): slash paths, e.g. inside #include "..."
"        DataFormats/L1THGC<C-x><C-u>  ->  DataFormats/L1THGCalDigi/
"    Python: dotted module paths (process.load / import style), aware that
"        Package.Sub.module maps to Package/Sub/python/module.py, and also
"        completes generated *_cfi modules from cfipython/
"
"  Directories complete with a trailing / or . - press <C-x><C-u> again to
"  descend a level. Tab/S-Tab cycles the menu, CR confirms (as everywhere).

function! CmsswPathComplete(findstart, base) abort
    if a:findstart
        let line  = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~# '[A-Za-z0-9_./-]'
            let start -= 1
        endwhile
        return start
    endif

    " Python completes dotted module paths unless a / says it's a real file path
    let dotted = &filetype ==# 'python' && a:base !~# '/'
    let token  = dotted ? substitute(a:base, '\.', '/', 'g') : a:base

    " [root, style] pairs. 'src' inserts the implicit python/ dir in dotted
    " mode; 'cfi' is the flat cfipython/<arch>/Pkg/Sub/x_cfi.py layout.
    let roots = []
    for base in [$CMSSW_BASE, $CMSSW_FULL_RELEASE_BASE, $CMSSW_RELEASE_BASE]
        if empty(base) | continue | endif
        call add(roots, [base . '/src', 'src'])
        if dotted && !empty($SCRAM_ARCH)
            call add(roots, [base . '/cfipython/' . $SCRAM_ARCH, 'cfi'])
        endif
    endfor

    let out  = []
    let seen = {}
    for [root, style] in roots
        if !isdirectory(root) | continue | endif
        let pat = token
        if dotted && style ==# 'src'
            let comps = split(token, '/', 1)
            if len(comps) >= 3
                let pat = comps[0] . '/' . comps[1] . '/python/' . join(comps[2:], '/')
            endif
        endif
        " nosuf=1: don't let wildignore silently hide results
        for hit in glob(root . '/' . pat . '*', 1, 1)
            let rel   = strpart(hit, len(root) + 1)
            let isdir = isdirectory(hit)
            if dotted
                if !isdir && rel !~# '\.py$' | continue | endif
                let rel  = substitute(rel, '/python/', '/', '')
                let rel  = substitute(rel, '\.py$', '', '')
                let word = substitute(rel, '/', '.', 'g') . (isdir ? '.' : '')
            else
                let word = rel . (isdir ? '/' : '')
            endif
            if has_key(seen, word) | continue | endif
            let seen[word] = 1
            call add(out, {'word': word, 'menu': isdir ? '/' : ''})
        endfor
    endfor
    return sort(out, {a, b -> a.word ==# b.word ? 0 : a.word ># b.word ? 1 : -1})
endfunction

set completefunc=CmsswPathComplete


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


