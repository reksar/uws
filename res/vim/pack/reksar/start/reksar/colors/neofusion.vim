" Vim color file
" Name: Neofusion
" Based On: https://github.com/diegoulloao/neofusion.nvim
" TODO: console colors

hi clear

if exists('syntax_on')
  syntax reset
endif

let g:colors_name = 'neofusion'

let s:normbg = ['#0d121f', 0]
let s:norm = ['#e3d8ce', 0]
let s:comment = ['#21506c', 0]
let s:const = ['#2c97d5', 0]
let s:type = ['#5bcbe4', 0]
let s:special = ['#f35b39', 0]
let s:statement = ['#cb6555', 0]
let s:bound = ['#031b27', 0]
let s:nontxt = ['#21506c', 0]

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
\  ['SpecialChar', 'NONE', s:type, s:bg],
\
\  ['Type', 'NONE', s:type, s:bg],
\  ['Pmenu', 'NONE', s:bg, s:type],
\  ['SuccessMsg', 'bold', s:bg, s:type],
\
\  ['Statement', 'NONE', s:statement, s:bg],
\  ['Question', 'bold', s:statement, s:bg],
\  ['StatusLineTerm', 'NONE', s:bg, s:statement],
\
\  ['CursorLine', 'NONE', s:no, s:bound],
\  ['CursorLineNr', 'bold', s:bound, s:nontxt],
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

hi! link Added Statement
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
hi! link IncSearch Visual
hi! link Include Statement
hi! link MoreMsg Type
hi! link Operator Special
hi! link PmenuBar LineNr
hi! link PreProc Constant
hi! link Removed Special
hi! link Search Visual
hi! link SignColumn LineNr
hi! link SpecialKey Special
hi! link StatusLineTermNC StatusLineTerm
hi! link TabLine StatusLine
hi! link TabLineFill StatusLineNC
hi! link Title Statement
hi! link WildMenu Todo
hi! link healthSuccess SuccessMsg
