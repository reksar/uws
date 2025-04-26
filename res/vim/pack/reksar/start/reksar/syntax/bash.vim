syn keyword shStatement cat dirname

" Override some shStatement keywords.
syn keyword shStatementBase exit for in declare

syn match shOperator /\(||\|&&\|&>\|1>\|2>\)/

" 'function_name()'
" NOTE: In the '$VIMRUNTIME/syntax/sh.vim' is defined higlighting for this
"       group, but there is no syntax defined there.
syn match shFunctionName /^\s*\w\+()/
" Parentheses in 'function_name()'.
syn match shParen /()/ contained containedin=shFunctionName

" '$' prefix
syn match shDerefSign /\$\ze\(\w\|@\|#\|\$\)/
\ contained
\ containedin=shDerefSimple

" '[<number>]' var suffix, e.g. '$var[0]' - is the 'shIndex'.
syn match shIndex /\[\d\+\]/
" '[]' braces are 'shIndexBound'.
syn match shIndexBound /\(\[\|\]\)/ contained containedin=shIndex
" This cluster is the next group after the 'shDerefSimple', e.g. '$var'.
" So we add the 'shIndex' to this cluster.
syn cluster shNoZSList add=shIndex

" '${...}' bounds
" Same as the defined in the '$VIMRUNTIME/syntax/sh.vim', but the 'matchgroup'
" redefined to 'shDerefSign' instead of 'PreProc'.
syn clear shDeref
syn region shDeref matchgroup=shDerefSign start=/\${/ end=/}/
\ contains=@shDerefList,shDerefVarArray
\ nextgroup=shSpecialStart
syn region shDeref matchgroup=shDerefSign start=/\${##\=/ end=/}/
\ contains=@shDerefList
\ nextgroup=@shSpecialNoZS,shSpecialStart
syn region shDeref matchgroup=shDerefSign start=/\${\$\$/ end=/}/
\ contains=@shDerefList
\ nextgroup=@shSpecialNoZS,shSpecialStart
syn region shDeref matchgroup=shDerefSign start=/\${!/ end=/\*\=}/
\ contains=@shDerefList,shDerefOffset

" '\' at the EOL.
" By default, this backslash is not highlighted inside a function definition.
syn cluster shCommandSubList add=shWrapLineOperator,shStatementBase

syn match	shTodo "\<\%(NOTE\|WARN\)\ze:\=\>" contained

hi link shArithRegion SpecialChar
hi link shArithmetic Operator
hi link shArithmetic SpecialChar
hi link shCharClass SpecialChar
hi link shCmdSubRegion SpecialChar
hi link shCommandSub Normal
hi link shConditional Statement
hi link shDeref Identifier
hi link shDerefSign SpecialChar
hi link shDerefSimple	Identifier
hi link shEcho Normal
hi link shIndexBound SpecialChar
hi link shNumber Normal
hi link shOption Identifier
hi link shParen Delimiter
hi link shQuote Constant
hi link shSnglCase Delimiter
hi link shSource Statement
hi link shSpecial SpecialChar
hi link shSpecialDQ SpecialChar
hi link shSpecialSQ SpecialChar
hi link shStatement Identifier
hi link shStatementBase Statement
hi link shVarAssign Operator
