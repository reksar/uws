" Use the 'wl-clipboard' for Wayland instead of standard clipboard.

if has('nvim') || empty($WAYLAND_DISPLAY)
  finish
endif

if executable('wl-copy')
  autocmd TextYankPost * 
  \ if (v:event.operator == 'y' || v:event.operator == 'd')
  \ | silent! execute 'call system("wl-copy", @")' 
  \ | endif
endif

if executable('wl-paste')
  nnoremap p :let @"=substitute(
  \   system('wl-paste --no-newline'), '<C-v><C-m>', '', 'g'
  \ )<CR>p
endif
