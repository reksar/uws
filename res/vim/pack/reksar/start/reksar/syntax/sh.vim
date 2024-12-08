if exists("b:current_syntax")
\ && b:current_syntax != "sh"
\ && b:current_syntax != "bash"
\ && b:current_syntax != "posix"
\ && b:current_syntax != "ksh"
  finish
endif

syn clear
source $VIMRUNTIME/syntax/sh.vim

let s:syntax_dir = $HOME . "/.vim/pack/reksar/start/reksar/syntax"

if getline(1) =~ '\<bash\>'
  exec "source " . s:syntax_dir . "/bash.vim"
endif
