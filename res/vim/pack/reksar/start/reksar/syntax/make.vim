if exists("b:current_syntax") && b:current_syntax != "make"
  finish
endif

syn clear
source $VIMRUNTIME/syntax/make.vim

syn keyword makeStatement
  \ abspath addprefix addsuffix and basename call dir error eval file
  \ filter-out filter findstring firstword flavor foreach guile if info join
  \ lastword notdir or origin patsubst realpath shell sort strip subst suffix
  \ value warning wildcard word wordlist words
\ contained

" makeIdent {{{
syn clear makeIdent

syn keyword makeStdVar MAKEFILE_LIST CURDIR

syn match makeStdIdent /.DEFAULT_GOAL/

syn match makeDerefDelim /,/ contained

if exists("b:make_microsoft") || exists("make_microsoft")

  syn region makeIdent matchgroup=makeDerefBound
  \ start=/\$(/ end=/)/
  \ contains=makeStatement,makeIdent,makeStdVar,makeDerefDelim

  syn region makeIdent matchgroup=makeDerefBound
  \ start=/\${/ end=/}/
  \ contains=makeStatement,makeIdent,makeStdVar,makeDerefDelim

else

  syn region makeIdent matchgroup=makeDerefBound
  \ start=/\$(/ skip=/\\)\|\\\\/ end=/)/
  \ contains=makeStatement,makeIdent,makeStdVar,makeDerefDelim

  syn region makeIdent matchgroup=makeDerefBound
  \ start=/\${/ skip=/\\}\|\\\\/ end=/}/
  \ contains=makeStatement,makeIdent,makeStdVar,makeDerefDelim

endif

syn match makeIdent /^\s*\zs\.\{-}\w\+\s*\(=\|:=\|+=\)/
\ contains=makeOperator,makeStdIdent

syn match makeOperator /:=\|=/ contained

syn match makeIdent /\$[@<^]/ contains=makeDerefBound
syn match makeDerefBound /\$/ contained
" makeIdent }}}

" makeTarget {{{
syn match makeTarget /^\(\s\|\w\|[$(){}\/.]\)*&\{-}:\([^=]\|$\)/
\ contains=makeTargetDelim,makeTargetGroup,makeIdent,makeSpecTarget

syn match makeTargetDelim /:\([^=]\|$\)/ contained

syn match makeTargetGroup /&/ contained nextgroup=makeTargetDelim
" makeTarget }}}

syn keyword makeTodo NOTE WARN contained

hi link makeCommands Normal
hi link makeComment Comment
hi link makeDerefBound SpecialChar
hi link makeDerefDelim Delimiter
hi link makeOperator Operator
hi link makeSpecTarget Type
hi link makeStdIdent Label
hi link makeStdVar Label
hi link makeTargetDelim Delimiter
hi link makeTargetGroup Operator
