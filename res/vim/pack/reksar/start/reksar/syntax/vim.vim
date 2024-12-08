if exists('b:current_syntax') && b:current_syntax != 'vim'
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/vim.vim

syn keyword vimLet const skipwhite nextgroup=vimVar,vimFuncVar

syn match vimScope "\<[abglstvw]:\ze\h"
\ containedin=vimVar,vimFBVar,vimFuncVar,vimFunc,vim9Variable

syn region vimOperParen matchgroup=vimSep start="\[" end="\]" transparent
\ contains=@vimOperGroup

syn match vimOper "\(?\|:\|&\)"

syn match vimSep ","
\ contained containedin=vimGroupList,vimOperParen,vimVarList,vim9VariableList

hi link vimCommentTitle SpecialComment
hi link vimDelimiter Delimiter
hi link vimEscape SpecialChar
hi link vimFuncParams Type
hi link vimFuncSID Type
hi link vimFTOption Keyword
hi link vimGroup Identifier
hi link vimGroupSpecial	Statement
hi link vimHiAttrib Constant
hi link vimLet Type
hi link vimNotFunc Statement
hi link vimScope Type
hi link vimSynOption Type
hi link vimSynType Keyword
hi link vimVarList Special
hi link vim9VariableList Special
