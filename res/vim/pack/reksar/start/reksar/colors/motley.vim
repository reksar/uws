" Vim colors file
" Description:
"   For 256-color terminals, see: https://jonasjacek.github.io/colors

set background=dark
hi clear
if exists('syntax_on')
	syntax reset
endif

let g:colors_name='motley'

" Syntax: --------------------------------------------------------------------

hi Normal guifg=#baae8f guibg=#21201d gui=none
hi Normal ctermfg=223 ctermbg=234 cterm=none

hi Keyword guifg=#baae8f guibg=#21201d gui=italic
hi Keyword ctermfg=223 ctermbg=234 cterm=italic

hi Statement guifg=#baae8f guibg=#21201d gui=bold
hi Statement ctermfg=223 ctermbg=234 cterm=bold

hi Conditional ctermfg=223 ctermbg=234 cterm=bold

hi Operator guifg=#baae8f guibg=#21201d gui=bold
hi Operator ctermfg=223 ctermbg=234 cterm=bold

hi Exception guifg=#baae8f guibg=#21201d gui=bold
hi Exception ctermfg=223 ctermbg=234 cterm=bold

hi PreProc guifg=#baae8f gui=italic
hi PreProc ctermfg=6 ctermbg=234 cterm=none

hi Include guifg=#baae8f gui=italic
hi Include ctermfg=223 ctermbg=234 cterm=italic

hi Macro guifg=#baae8f gui=italic
hi PreCondit guifg=#baae8f gui=italic

hi Define guifg=#7dadae guibg=#21201d gui=italic
hi Define ctermfg=223 ctermbg=234 cterm=italic

hi Identifier guifg=#d08f48 guibg=#21201d gui=none
hi Identifier ctermfg=116 ctermbg=234 cterm=none

hi Function guifg=#afaf3f guibg=#21201d gui=none
hi Function ctermfg=184 ctermbg=234 cterm=none

hi Label guifg=#afaf3f guibg=#21201d gui=bold
hi Label ctermfg=223 ctermbg=234 cterm=bold

hi String guifg=#ebdbb2 guibg=#21201d gui=none
hi String ctermfg=180 ctermbg=234 cterm=none

hi Comment guifg=#777777 guibg=#21201d gui=italic
hi Comment ctermfg=246 ctermbg=234 cterm=italic

hi SpecialComment guifg=#777777 guibg=#21201d gui=bold
hi SpecialComment ctermfg=223 ctermbg=234 cterm=none

hi SpecialChar guifg=#d08f48 guibg=#21201d
hi SpecialChar ctermfg=155 ctermbg=234 cterm=none

hi Special guifg=#d08f48 guibg=#21201d gui=none
hi Special ctermfg=155 ctermbg=234 cterm=none

hi Tag guifg=#d08f48 guibg=#21201d
hi Delimiter guifg=#d08f48 guibg=#21201d
hi Debug guifg=#d08f48 guibg=#21201d
hi Constant guifg=#d35d41 guibg=#21201d gui=none
hi Number guifg=#d35d41 guibg=#21201d gui=none

hi Type guifg=#7dadae guibg=#21201d gui=none
hi Type ctermfg=222 ctermbg=234 gui=none

hi StorageClass guifg=#7dadae guibg=#21201d gui=italic
hi StorageClass ctermfg=223 ctermbg=234 cterm=italic

hi Structure guifg=#7dadae guibg=#21201d gui=italic
hi Structure ctermfg=223 ctermbg=234 cterm=italic

hi Typedef guifg=#7dadae guibg=#21201d gui=none
hi Ignore guifg=#777777

" Marked Text: ---------------------------------------------------------------
hi Search guifg=#ffcc00 guibg=#21201d gui=inverse
hi IncSearch guifg=#b5ee00 guibg=#21201d gui=inverse
hi Visual guibg=#111111 gui=reverse
hi Folded guifg=#baae8f guibg=#21201d gui=bold
hi Todo guifg=#afaf3f guibg=#21201d gui=inverse
hi Error guifg=#d35d41 guibg=#21201d gui=inverse

" Interface Bounds: ----------------------------------------------------------
"
hi NonText guifg=#8b8bcd guibg=#292929 gui=bold

hi LineNr guifg=#9a8b7b guibg=#292929 gui=none
hi LineNr ctermfg=244 ctermbg=235 cterm=none

hi ColorColumn guibg=#292929
hi ColorColumn ctermbg=236

hi Statusline guifg=#ebdbb2 guibg=#000000
hi ErrorMsg guifg=#111111 guibg=#d35d41 gui=bold

" Cursor Indicators: ---------------------------------------------------------
hi Cursor guifg=#111111 guibg=#75eba0

hi CursorLine guibg=#111111
hi CursorLine ctermbg=232 cterm=none

hi CursorLineNr guifg=#baae8f guibg=#21201d
hi CursorLineNr ctermfg=244 ctermbg=232 cterm=bold

" Menu: ----------------------------------------------------------------------
hi Pmenu guifg=#333333 guibg=#cfbfad
hi PmenuSel guifg=#111111 guibg=#baae8f gui=bold

" Brackets: ------------------------------------------------------------------
hi MatchParen guifg=#55FFFF guibg=#111111 gui=bold,underline
hi MatchParen ctermfg=39 ctermbg=234 cterm=bold,underline

