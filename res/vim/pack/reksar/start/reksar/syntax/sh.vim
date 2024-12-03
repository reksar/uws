if exists("b:current_syntax")
\ && b:current_syntax != "sh"
\ && b:current_syntax != "bash"
\ && b:current_syntax != "posix"
\ && b:current_syntax != "ksh"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/sh.vim

syn clear shStatement
if b:current_syntax == "bash"
  syn clear bashStatement
elseif b:current_syntax == "ksh"
  syn clear kshStatement
endif
syn keyword shStatement exit return shift

" && ||
syn match shCtrlOperator "[&|]\{2}"

syn clear shDeref
syn region shDeref matchgroup=shDerefBounds start="\${" end="}"
  \ contains=@shDerefList,shDerefVarArray
  \ nextgroup=shSpecialStart
if exists("b:is_bash") || exists("b:is_kornshell") || exists("b:is_posix")
  syn region shDeref matchgroup=shDerefBounds start="\${##\=" end="}"
    \ contains=@shDerefList
    \ nextgroup=@shSpecialNoZS,shSpecialStart
  syn region shDeref matchgroup=shDerefBounds start="\${\$\$" end="}"
    \ contains=@shDerefList
    \ nextgroup=@shSpecialNoZS,shSpecialStart
endif
if exists("b:is_bash")
  syn region shDeref matchgroup=shDerefBounds start="\${!" end="\*\=}"
    \ contains=@shDerefList,shDerefOffset
endif
if exists("b:is_kornshell") || exists("b:is_posix")
  syn region shDeref matchgroup=shDerefBounds start="\${!" end="}"
    \ contains=@shDerefVarArray
endif

syn clear shCommandSubBQ
syn region shCommandSubBQ matchgroup=shCommandSubBounds
  \ start="`" skip="\\\\\|\\." end="`"
  \ contains=shBQComment,@shCommandSubList

hi link shArithRegion Special
hi link shCmdSubRegion Special
hi link shCommandSub Normal
hi link shCommandSubBounds Special
hi link shCtrlOperator Statement
hi link shDerefBounds Special
hi link shOption Normal
hi link shRange Special
hi link shSet Type
hi link shSpecialStart Special
hi link shString Constant
hi link shWrapLineOperator Type
