" Vim color file
" Name: Alexstrasza

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'alexstrasza'
let s:is_dark = (&background == 'dark')

let s:normbg = s:is_dark ? ['#292522', 235] : ['#eeeeee', 255]
let s:norm = s:is_dark ? ['#e3d8ce', 188] : ['#080808', 232]
let s:comment = s:is_dark ? ['#9b8671', 138] : ['#808080', 244]
let s:const = s:is_dark ? ['#d6bf9c', 179] : ['#005f00', 22]
let s:type = s:is_dark ? ['#70b0b0', 111] : ['#005faf', 25]
let s:special = s:is_dark ? ['#c04939', 167] : ['#af5f00', 130]
let s:search = s:is_dark ? ['#f8b659', 167] : ['#af5f00', 130]
let s:searchbg = s:is_dark ? ['#000000', 167] : ['#af5f00', 130]
let s:ok = s:is_dark ? ['#b1b325', 148] : ['#005faf', 25]
let s:bound = s:is_dark ? ['#1b1a18', 233] : ['#e4e4e4', 254]
let s:nontxt = s:is_dark ? ['#585858', 240] : ['#a8a8a8', 248]

let s:fg = ['fg', 'fg']
let s:bg = ['bg', 'bg']
let s:no = ['NONE', 'NONE']

for [name, style, fg, bg] in [
\
\  ['Normal', 'NONE', s:norm, s:normbg],
\  ['TabLineSel', 'NONE', s:bg, s:fg],
\  ['FoldColumn', 'bold', s:normbg, s:norm],
\
\  ['Comment', 'NONE', s:comment, s:bg],
\  ['Todo', 'inverse', s:comment, s:bg],
\  ['SpecialComment', 'bold', s:comment, s:bg],
\  ['StatusLine', 'NONE', s:bound, s:comment],
\
\  ['Constant', 'NONE', s:const, s:bg],
\  ['WarningMsg', 'bold', s:bg, s:const],
\
\  ['Type', 'NONE', s:type, s:bg],
\  ['SpecialChar', 'NONE', s:type, s:bg],
\  ['SuccessMsg', 'bold', s:bg, s:type],
\
\  ['Special', 'NONE', s:special, s:bg],
\  ['DiagnosticWarn', 'bold', s:special, s:bg],
\  ['DiffDelete', 'NONE', s:bg, s:special],
\  ['Error', 'bold,inverse', s:special, s:bg],
\  ['MatchParen', 'bold,underline,inverse', s:bg, s:special],
\
\  ['Added', 'NONE', s:ok, s:bg],
\  ['Question', 'bold', s:ok, s:bg],
\  ['StatusLineTerm', 'NONE', s:bg, s:ok],
\
\  ['CursorLine', 'NONE', s:no, s:bound],
\  ['CursorLineNr', 'bold', s:bound, s:nontxt],
\  ['NonText', 'NONE', s:nontxt, s:bg],
\  ['LineNr', 'NONE', s:nontxt, s:bound],
\  ['StatusLineNC', 'NONE', s:bg, s:nontxt],
\  ['Pmenu', 'NONE', s:const, s:nontxt],
\  ['PmenuSel', 'inverse', s:no, s:no],
\
\  ['Visual', 'inverse', s:searchbg, s:search],
\]
  exe 'hi '.name.' gui='.style.' cterm='.style
  \  .' guifg='.fg[0].' guibg='.bg[0].' ctermfg='.fg[1].' ctermbg='.bg[1]
endfor

hi DiagnosticError guifg=#dd3f19 guibg=bg gui=bold
hi DiagnosticSignError guifg=#dd3f19 guibg=#1b1a18 gui=bold

hi! link Changed Type
hi! link ColorColumn CursorLine
hi! link Conditional Operator
hi! link Delimiter Special
hi! link DiffAdd Pmenu
hi! link DiffChange StatusLine
hi! link Directory Constant
hi! link ErrorMsg Error
hi! link Folded CursorLineNr
hi! link Identifier Normal
hi! link Include Statement
hi! link IncSearch Visual
hi! link MoreMsg Type
hi! link Operator Special
hi! link PmenuBar LineNr
hi! link PreProc Constant
hi! link Removed Special
hi! link Search Visual
hi! link SpecialKey Special
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLine StatusLine
hi! link TabLineFill StatusLineNC
hi! link Title Statement
hi! link WildMenu Todo
hi! link SignColumn LineNr
hi! link healthSuccess SuccessMsg
hi! link Statement Type
