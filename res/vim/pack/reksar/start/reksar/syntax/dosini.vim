if exists("b:current_syntax") && b:current_syntax != "dosini"
  finish
endif

" using of line-continuation requires cpo&vim
let s:cpo_save = &cpo
set cpo&vim

syn case ignore


" At the start of line or after at least 2 spaces.
syn match dosiniComment "\(^\|\s\{2,}\)[#;].*$" contains=@Spell

syn region dosiniHeader matchgroup=dosiniHeaderBrackets start="^\s*\[" end="\]"
\ oneline

" A word at the start of line.
syn match dosiniLabel "^\s*\w\+" nextgroup=dosiniEqual
syn match dosiniEqual /=/

syn region dosiniSection start="\s*\[.*\]" end="\ze\s*\[.*\]" fold
\ contains=dosiniHeader,dosiniLabel,dosiniComment


hi link dosiniComment Comment
hi link dosiniHeader Label
hi link dosiniHeaderBrackets Delimiter
hi link dosiniLabel Constant
hi link dosiniEqual Operator


let b:current_syntax = "dosini"

let &cpo = s:cpo_save
unlet s:cpo_save

" vim: sts=2 sw=2 et
