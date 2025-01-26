if exists("b:current_syntax") && b:current_syntax != "python"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/python.vim

syn match pythonDelimiter /[.,:]/
syn match pythonParens /[\[\](){}]/
syn match pythonCalc /=\|<\|>\|+\|-\|\*\|\/\||\|\^\|%\|!/

syn clear pythonStatement
syn keyword pythonStatement	with as assert break continue del exec global
syn keyword pythonStatement lambda nonlocal pass return yield class
syn keyword pythonConst None True False

" Strings {{{

syn clear pythonString pythonRawString pythonTripleQuotes pythonQuotes

" plain string
syn match pythonString /\('.\{-}'\|".\{-}"\)/
\ contains=pythonEscape,@Spell

" formatted string
syn match pythonFormattedString /\('.\{-}'\|".\{-}"\)\s*%/
\ contains=pythonStringPresentation,pythonPresentationType,pythonEscape,@Spell
syn match pythonStringPresentation /['"]\s*\zs%/
\ contained
syn match pythonPresentationType /%[bcdeEfFgnorsxX]/
\ contained

" comment
syn region pythonComment start=/^\s*\z('''\|"""\)/ end=/\z1/ keepend
\ contains=pythonEscape,pythonSpaceError,pythonDoctest,@Spell

" f-string
syn match pythonFStringType /\<f\('.\{-}'\|".\{-}"\)/
\ contains=pythonFString
syn match pythonFString /\('.\{-}'\|".\{-}"\)/
\ contained
\ contains=pythonStringExpr,pythonEscape,@Spell

" f-string multiline
syn region pythonFStringType
\ start=/\<f\z('''\|"""\)/
\ end=/\z1/
\ skip=/\\\\\|\\\z1/
\ keepend
\ contains=pythonFString
syn region pythonFString matchgroup=pythonQuotes
\ start=/\z('''\|"""\)/
\ end=/\z1/
\ skip=/\\\\\|\\\z1/
\ keepend
\ contained
\ contains=pythonStringExpr,pythonEscape,pythonSpaceError,@Spell

" bytes
syn match pythonBStringType /\<b\('.\{-}'\|".\{-}"\)/
\ contains=pythonString

" bytes multiline
syn region pythonBStringType
\ start=/\<b\z('''\|"""\)/
\ end=/\z1/
\ skip=/\\\\\|\\\z1/
\ keepend
\ contains=pythonBString
syn region pythonBString matchgroup=pythonQuotes
\ start=/\z('''\|"""\)/
\ end=/\z1/
\ skip=/\\\\\|\\\z1/
\ keepend
\ contained
\ contains=pythonEscape,pythonSpaceError,@Spell

" raw string
syn match pythonRStringType /\<r\('.\{-}'\|".\{-}"\)/
\ contains=pythonRString
syn match pythonRString /\('.\{-}'\|".\{-}"\)/
\ contained

" raw string multiline
syn region pythonRStringType
\ start=/\<r\z('''\|"""\)/
\ end=/\z1/
\ keepend
\ contains=pythonRString
syn region pythonRString matchgroup=pythonQuotes
\ start=/\z('''\|"""\)/
\ end=/\z1/
\ keepend
\ contained

syn region pythonStringExpr matchgroup=pythonParens
\ start=/{\{1,2}/
\ end=/}\{1,2}/
\ keepend
\ contained
\ contains=pythonDelimiter,pythonParens,pythonCalc,pythonConst

" String }}}

" def {{{

syn region pythonDef start=/^\s*def\s\+\h\w*\s*(/ end=/).\{-}:/ keepend
\ contains=pythonFunction,pythonDefArgs,pythonDelimiter,pythonParens,
\   pythonCalc,pythonConst

syn clear pythonFunction
syn match pythonFunction /\<\h\w*\ze\s*(/ nextgroup=pythonDefArgs skipwhite
\ contained

syn region pythonDefArgs matchgroup=pythonParens start=/(/ end=/)/
\ contained
\ contains=pythonDelimiter,pythonParens,pythonCalc,pythonConst,pythonArgType,
\   pythonArgTypes

syn match pythonArgType /:\s*\h\(\w\|\.\)*/ nextgroup=pythonArgTypes skipwhite
\ contained
\ contains=pythonDelimiter

syn region pythonArgTypes matchgroup=pythonParens start=/\[/ end=/\]/
\ contained
\ contains=pythonParens,pythonDelimiter

" def }}}

hi link pythonArgType Type
hi link pythonArgTypes Type
hi link pythonBString Constant
hi link pythonBStringType Type
hi link pythonCalc Delimiter
hi link pythonConditional Statement
hi link pythonConst Constant
hi link pythonDecorator Special
hi link pythonDef Type
hi link pythonDefArgs Identifier
hi link pythonDelimiter Delimiter
hi link pythonExceptions Identifier
hi link pythonFString Constant
hi link pythonFStringType Type
hi link pythonFormattedString Constant
hi link pythonFunction Identifier
hi link pythonOperator Statement
hi link pythonParens Delimiter
hi link pythonPresentationType Type
hi link pythonQuotes Constant
hi link pythonRString Constant
hi link pythonRStringType Type
hi link pythonString Constant
hi link pythonStringPresentation Type
