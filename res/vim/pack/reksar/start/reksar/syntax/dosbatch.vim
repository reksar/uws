if !exists("b:current_syntax") || b:current_syntax != "dosbatch"
  finish
endif

syn keyword dosbatchCommentKeyword rem
syn keyword dosbatchRepeat in do

syn match dosbatchVarBound "%"
  \ containedin=dosbatchVariable
syn match dosbatchVariable "%\h\w*%"
syn match dosbatchVariable "%\h\w*:\*\=[^=]*=[^%]*%"
syn match dosbatchVariable "%\h\w*:\~[-]\=\d\+\(,[-]\=\d\+\)\=%"
  \ contains=dosbatchInteger

syn match dosbatchVarBound "!"
  \ containedin=dosbatchVariable
syn match dosbatchVariable "!\h\w*!"
syn match dosbatchVariable "!\h\w*:\*\=[^=]*=[^!]*!"
syn match dosbatchVariable "!\h\w*:\~[-]\=\d\+\(,[-]\=\d\+\)\=!"
  \ contains=dosbatchInteger

hi link dosbatchCommentKeyword Type
hi link dosbatchImplicit Statement
hi link dosbatchSwitch Function
hi link dosbatchVarBound Special
