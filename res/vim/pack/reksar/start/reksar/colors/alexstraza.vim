" Vim color file
" Name: Alexstraza
" See: 256-color palette - https://jonasjacek.github.io/colors

hi clear

if version > 580
  if exists("syntax_on")
    syntax reset
  endif
endif

let g:colors_name = "alexstraza"

let s:fg = ['fg', 'fg']
let s:bg = ['bg', 'bg']
let s:no = ['NONE', 'NONE']

let s:is_dark = (&background == "dark")

let s:norm = s:is_dark ? ['#baae8f', 180] : ['#080808', 232]
let s:normbg = s:is_dark ? ['#21201d', 234] : ['#eeeeee', 255]
let s:comment = s:is_dark ? ['#8a8a8a', 245] : ['#808080', 244]
let s:const = s:is_dark ? ['#edcd98', 179] : ['#005f00', 22]
let s:special = s:is_dark ? ['#a75b51', 167] : ['#af5f00', 130]
let s:type = s:is_dark ? ['#687b6d', 65] : ['#005faf', 25]
let s:bound = s:is_dark ? ['#1b1a18', 233] : ['#e4e4e4', 254]
let s:nontxt = s:is_dark ? ['#585858', 240] : ['#a8a8a8', 248]

for [name, style, fg, bg] in [
\
\  ['Normal', 'NONE', s:norm, s:normbg],
\  ['Statement', 'bold', s:fg, s:bg],
\  ['TabLineSel', 'NONE', s:bg, s:fg],
\
\  ['Comment', 'NONE', s:comment, s:bg],
\  ['SpecialComment', 'bold', s:comment, s:bg],
\  ['StatusLine', 'NONE', s:bg, s:comment],
\  ['WarningMsg', 'bold', s:bg, s:comment],
\
\  ['Constant', 'NONE', s:const, s:bg],
\  ['Todo', 'inverse', s:comment, s:bg],
\
\  ['Special', 'NONE', s:special, s:bg],
\  ['DiagnosticWarn', 'bold', s:special, s:bg],
\  ['DiffDelete', 'NONE', s:bg, s:special],
\  ['Error', 'bold,inverse', s:special, s:bg],
\  ['MatchParen', 'bold,underline,inverse', s:bg, s:special],
\
\  ['Type', 'NONE', s:type, s:bg],
\  ['Pmenu', 'NONE', s:bg, s:type],
\  ['SuccessMsg', 'bold', s:bg, s:type],
\
\  ['CursorLine', 'NONE', s:no, s:bound],
\  ['CursorLineNr', 'bold', s:comment, s:bound],
\
\  ['NonText', 'NONE', s:nontxt, s:bg],
\  ['LineNr', 'NONE', s:nontxt, s:bound],
\  ['StatusLineNC', 'NONE', s:bg, s:nontxt],
\  ['PmenuSel', 'NONE', s:const, s:nontxt],
\
\  ['Visual', 'inverse', s:no, s:no],
\]
  exe 'hi '.name.' gui='.style.' cterm='.style
  \  .' guifg='.fg[0].' guibg='.bg[0].' ctermfg='.fg[1].' ctermbg='.bg[1]
endfor

hi DiagnosticError guifg=#dd3f19 guibg=bg gui=bold
hi DiagnosticSignError guifg=#dd3f19 guibg=#1b1a18 gui=bold

hi! link ColorColumn CursorLine
hi! link DiffAdd Pmenu
hi! link DiffChange StatusLine
hi! link Directory Constant
hi! link ErrorMsg Error
hi! link Folded SuccessMsg
hi! link Identifier Normal
hi! link Include Statement
hi! link IncSearch Visual
hi! link MoreMsg Type
hi! link PmenuBar LineNr
hi! link PreProc Constant
hi! link Search Visual
hi! link SpecialKey Special
hi! link Question Type
hi! link TabLine StatusLine
hi! link TabLineFill StatusLineNC
hi! link Title Statement
hi! link WildMenu Todo
hi! link SignColumn LineNr
hi! link healthSuccess SuccessMsg
