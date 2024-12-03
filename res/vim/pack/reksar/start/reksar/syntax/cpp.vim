if !exists("b:current_syntax") || b:current_syntax != "cpp"
  syn clear

  " NOTE: the `runtime` has deviant behavior, so `source` is used here to apply
  " default C++ syntax.
  " NOTE: some default syntax will be clear and redefined below.
  source $VIMRUNTIME/syntax/cpp.vim
endif


"syn clear cStorageClass
"syn clear cStructure
"syn clear cppStructure
"syn clear cType
"syn clear cppType
"syn clear cppAccess
"syn clear cppModifier


syn clear
let b:current_syntax = "cpp"

" Start of line followed by spaces and #
syn match cppMacroStart /^\s*#/
  \ nextgroup=cppMacroName

" Start of line followed by spaces, but not #
syn match cppStart /^\s*[^#]/
  \ nextgroup=cppModifier,cppType

syn keyword cppModifier const static virtual
  \ contained
  \ nextgroup=cppModifier,cppType
  \ skipwhite

"                     type&*  >|
syn match cppType /\<\i\+[&*]*\ze\_s/
  \ contained
  \ nextgroup=cppFuncDef
  \ skipwhite
  \ skipempty


" Func Def: ------------------------------------------------------------------

"                         name::       func   (
syn match cppFuncDef /\<\(\i\+::\)\{,1}\i\+\ze(/
  \ contained
  \ contains=cppNameScope
  \ nextgroup=cppFuncDefArgs

"                         name::
syn match cppNameScope /\<\i\+::/
  \ contained

syn region cppFuncDefArgs start=/(/ end=/)/
  \ contained
  \ contains=cppFuncDefArg
  \ keepend
  \ nextgroup=cppMethodModifier,cppBlock
  \ skipwhite
  \ skipempty

syn match cppFuncDefArg /\(const\s\+\)\{,1}\<\i\+[&*]*\s\+\i\+/
  \ contained
  \ contains=cppFuncDefArgModifier,cppFuncDefArgType

syn keyword cppFuncDefArgModifier const
  \ contained

syn match cppFuncDefArgType /\<\i\+[&*]*\ze\s\+\</
  \ contained

syn keyword cppMethodModifier const
  \ contained
  \ nextgroup=cppBlock
  \ skipwhite
  \ skipempty

syn region cppBlock matchgroup=cppBlockBounds start=/{/ end=/}/
  \ contained
  \ keepend

" ------------------------------------------------------------------- Func Def

syn match cppMacroName /^\s*#\<\w\+\>/
  \ contains=cppMacroStart

syn keyword cppMacroCondition if ifdef ifndef else elif endif
  \ containedin=cppMacroName

hi link cppBlock Function
hi link cppBlockBounds Special
hi link cppFuncDef Function
hi link cppFuncDefArg Identifier
hi link cppFuncDefArgModifier StorageClass
hi link cppFuncDefArgType Type
hi link cppMacroStart Special
hi link cppMacroCondition Statement
hi link cppMethodModifier StorageClass
hi link cppModifier StorageClass
hi link cppNameScope Type
hi link cppType Type
