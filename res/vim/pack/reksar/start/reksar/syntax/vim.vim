if exists('b:current_syntax') && b:current_syntax != 'vim'
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/vim.vim

syn keyword vimStatement en[dif] for endfo[r] fini[sh]
  \ containedin=vimIsCommand,vimFuncList,vimSyntax,vimAuSyntax

syn keyword vimLet const skipwhite nextgroup=vimVar,vimFuncVar

syn match vimScope "\<[abglstvw]:\ze\h"
  \ containedin=vimVar,vimFBVar,vimFuncVar,vimFunc

syn region vimOperParen matchgroup=vimSep start="\[" end="\]" transparent
  \ contains=@vimOperGroup

hi link vimCommentTitle SpecialComment
hi link vimFuncSID Type
hi link vimFTOption Keyword
hi link vimGroup Identifier
hi link vimHiAttrib Constant
hi link vimLet Type
hi link vimNotFunc Statement
hi link vimOper Normal
hi link vimScope Type
hi link vimSynOption Type
hi link vimSynType Keyword
