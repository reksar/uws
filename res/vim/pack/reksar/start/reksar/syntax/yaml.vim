if exists("b:current_syntax") && b:current_syntax != "yaml"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/yaml.vim

syn region yamlBlockString start=/^\z(\s\+\)/ skip=/^$/ end=/^\%(\z1\)\@!/
\ contained
\ contains=yamlBool

syn region yamlFlowStringVar matchgroup=yamlDoubleBraces start=/{{/ end=/}}/
\ keepend
\ contains=yamlBool
\ containedin=yamlFlowString,yamlBlockStr

syn match yamlVarDelimiter /\({\|}\|(\|)\||\|,\|\.\|=\|:\|!\)/
\ containedin=yamlBlockString,yamlFlowStringVar,yamlNodeTag

syn region yamlBlockStr matchgroup=yamlFlowStringDelimiter
\ start=/"/ skip=/\\"/ end=/"/
\ contains=yamlEscape
\ skipwhite
\ containedin=yamlBlockString

syn region yamlBlockStr matchgroup=yamlFlowStringDelimiter
\ start=/'/ skip=/\\'/ end=/'/
\ contains=yamlEscape
\ skipwhite
\ containedin=yamlBlockString

syn keyword yamlOpKey is or and not
\ contained
\ containedin=yamlBlockString,yamlFlowStringVar,yamlPlainScalar

hi link yamlBlockCollectionItemStart Delimiter
hi link yamlBlockMappingKey Type
hi link yamlBlockMappingMerge Delimiter
hi link yamlBlockScalarHeader Label
hi link yamlBlockStr Constant
hi link yamlConstant Label
hi link yamlDocumentStart Delimiter
hi link yamlDoubleBraces Delimiter
hi link yamlFlowMappingMerge Delimiter
hi link yamlFlowStringVar Normal
hi link yamlKeyValueDelimiter Delimiter
hi link yamlMappingKeyStart Delimiter
hi link yamlOpKey Label
hi link yamlVarDelimiter Operator
