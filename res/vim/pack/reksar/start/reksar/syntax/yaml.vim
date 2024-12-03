if exists("b:current_syntax") && b:current_syntax != "yaml"
  finish
endif

" Manually load default syntax first to override it.
syn clear
source $VIMRUNTIME/syntax/yaml.vim

syn match yamlOperator /\s\+==\s\+/

syn region yamlFlowMapping matchgroup=yamlFlowIndicator start=/{/ end=/}/
  \ contains=@yamlFlow

syn region yamlStrVar matchgroup=SpecialChar start=/{{/ end=/}}/
  \ keepend transparent containedin=yamlFlowString

hi link yamlBlockCollectionItemStart SpecialChar
hi link yamlKeyValueDelimiter Delimiter
hi link yamlBlockMappingMerge Delimiter
hi link yamlMappingKeyStart Delimiter
hi link yamlFlowMappingMerge Delimiter
hi link yamlFlowIndicator Delimiter
hi link yamlOperator Operator
