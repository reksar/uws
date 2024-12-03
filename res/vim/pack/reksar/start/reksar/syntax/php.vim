if exists("b:current_syntax") && b:current_syntax != "php"
  finish
endif

syn keyword phpDefine define contained
syn keyword phpFunctions filter_var
syn keyword phpOperator new clone contained

hi link phpKeyword StorageClass
hi link phpInterpMethodName Identifier
hi link phpMethodsVar Identifier
hi link phpInterpComplex Identifier
hi link phpVarSelector Delimiter
