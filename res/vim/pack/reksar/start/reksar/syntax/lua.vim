if exists("b:current_syntax") && b:current_syntax != "lua"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/lua.vim

syn clear luaStatement
syn keyword luaStatement return break goto

syn keyword luaScope local

syn clear luaParen
syn region luaParen matchgroup=luaParentheses start='(' end=')'
  \ transparent
  \ contains=ALLBUT,luaParenError,luaTodo,luaSpecial,luaIfThen,luaElseifThen,luaElse,luaThenEnd,luaBlock,luaLoopBlock,luaIn,luaStatement


hi link luaFunction Statement
hi link luaScope Type
hi link luaParentheses Special
hi link luaTable Special
