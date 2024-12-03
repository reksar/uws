" For 256-color terminals, see: https://jonasjacek.github.io/colors
set background=dark
hi clear
if exists('syntax_on')
	syntax reset
endif

let colors_name='lowcolor'

" Syntax: --------------------------------------------------------------------
hi Normal ctermfg=150 ctermbg=234 cterm=none
hi Normal guifg=#96925f guibg=#21201d gui=none
hi Keyword ctermfg=222 ctermbg=234 cterm=none
hi Keyword guifg=#aa8060 guibg=#21201d gui=none
hi Statement ctermfg=223 ctermbg=234 cterm=bold
hi Statement guifg=#baae8f guibg=#21201d gui=bold
hi Identifier ctermfg=223 ctermbg=234 cterm=none
hi Identifier guifg=#baae8f guibg=#21201d gui=none
hi Label ctermfg=223 ctermbg=234 cterm=bold
hi Label guifg=#baae8f guibg=#21201d gui=bold
hi Function ctermfg=223 ctermbg=234 cterm=none
hi Function guifg=#baae8f guibg=#21201d gui=none
hi String ctermfg=179 ctermbg=234 cterm=none
hi String guifg=#edcd98 guibg=#21201d gui=none
hi Special ctermfg=246 ctermbg=234 cterm=bold
hi Special guifg=#777777 guibg=#21201d gui=bold
hi Delimiter ctermfg=137 ctermbg=234 cterm=none
hi Delimiter guifg=#aa8060 guibg=#21201d gui=none
hi Constant ctermfg=186 ctermbg=234 cterm=none
hi Constant guifg=#edcd98 guibg=#21201d gui=none
hi SpecialChar ctermfg=151 ctermbg=234 cterm=none
hi SpecialChar guifg=#d08f48 guibg=#21201d
hi Number ctermfg=186 ctermbg=234 cterm=none
hi Number guifg=#edcd98 guibg=#21201d gui=none
hi Type ctermfg=137 ctermbg=234 cterm=none
hi Type guifg=#ccc281 guibg=#21201d gui=none
hi Comment ctermfg=246 ctermbg=234 cterm=italic
hi Comment guifg=#777777 guibg=#21201d gui=italic
hi SpecialComment ctermfg=246 ctermbg=234 cterm=bold
hi SpecialComment guifg=#777777 guibg=#21201d gui=bold
hi PreProc ctermfg=150 ctermbg=234 cterm=italic
hi PreProc guifg=#baae8f guibg=#21201d gui=italic
hi Operator ctermfg=223 ctermbg=234 cterm=none
hi Operator guifg=#baae8f guibg=#21201d gui=bold
hi StorageClass ctermfg=223 ctermbg=234 cterm=italic
hi StorageClass guifg=#7dadae guibg=#21201d gui=none
hi Structure ctermfg=223 ctermbg=234 cterm=italic
hi Structure guifg=#7dadae guibg=#21201d gui=none
hi Define ctermfg=223 ctermbg=234 cterm=italic
hi Define guifg=#7dadae guibg=#21201d
hi Include ctermfg=223 ctermbg=234 cterm=italic
hi Include guifg=#baae8f gui=italic
hi Exception ctermfg=223 ctermbg=234 cterm=bold
hi Exception guifg=#baae8f guibg=#21201d gui=bold
hi Noise ctermfg=234 ctermbg=124 cterm=none



hi Macro guifg=#baae8f gui=italic
hi PreCondit guifg=#baae8f gui=italic
hi Tag guifg=#d08f48 guibg=#21201d
hi Debug guifg=#d08f48 guibg=#21201d
hi Typedef guifg=#7dadae guibg=#21201d gui=none
hi Ignore guifg=#777777

" Marked Text: ---------------------------------------------------------------
hi Search guifg=#ffcc00 guibg=#21201d gui=inverse
hi IncSearch guifg=#b5ee00 guibg=#21201d gui=inverse
hi Visual guibg=#111111 gui=reverse
hi Folded guifg=#baae8f guibg=#21201d gui=bold
hi Todo guifg=#afaf3f guibg=#21201d gui=inverse
hi Error guifg=#d35d41 guibg=#21201d gui=inverse
hi Error ctermfg=234 ctermbg=124 cterm=none

" Border Interface: ----------------------------------------------------------
hi NonText      guifg=#8b8bcd guibg=#292929 gui=bold
hi LineNr guifg=#9a8b7b guibg=#292929 gui=none
hi LineNr ctermfg=242 ctermbg=235 cterm=none
hi ColorColumn guibg=#292929
hi ColorColumn ctermfg=223 ctermbg=235
hi Statusline guifg=#ebdbb2 guibg=#000000
hi ErrorMsg guifg=#111111 guibg=#d35d41 gui=bold

" Cursor Indicators: ---------------------------------------------------------
hi Cursor guifg=#111111 guibg=#75eba0
hi CursorLine guibg=#111111
hi CursorLine ctermbg=235 cterm=none
hi CursorLineNr guifg=#baae8f guibg=#21201d
hi CursorLineNr ctermfg=242 ctermbg=234 cterm=none

" Menu: ----------------------------------------------------------------------
hi Pmenu guifg=#333333 guibg=#cfbfad
hi PmenuSel guifg=#111111 guibg=#baae8f gui=bold

" Brackets: ------------------------------------------------------------------
hi MatchParen ctermfg=234 ctermbg=208 cterm=bold,underline,inverse
hi MatchParen guifg=#55FFFF guibg=#111111 gui=bold,underline
