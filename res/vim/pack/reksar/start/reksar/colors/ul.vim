" Vim color file
" Name: ul - universal lowcolor
" 256-color palette: https://jonasjacek.github.io/colors

highlight clear

let s:is_dark=(&background == "dark")

if s:is_dark
  set background=dark
else
  set background=light
endif

if version > 580
  if exists("syntax_on")
    syntax reset
  endif
endif

let g:colors_name = "ul"

if s:is_dark

  if has("gui_running")

    hi Normal guifg=#eeeeee guibg=#262626 gui=none
    hi Statement guifg=#eeeeee guibg=#262626 gui=bold

    hi Comment guifg=#949494 guibg=#262626 gui=none
    hi SpecialComment guifg=#949494 guibg=#262626 gui=bold

    hi Todo guifg=#262626 guibg=#d7af5f gui=none

    hi Constant guifg=#d7d75f guibg=#262626 gui=none
    hi PreProc guifg=#d7d75f guibg=#262626 gui=none

    hi Type guifg=#afd7ff guibg=#262626 gui=none

    hi Special guifg=#5fd7ff guibg=#262626 gui=none

    hi CursorLine guibg=#1c1c1c gui=none
    hi CursorLineNr guifg=#949494 guibg=#1c1c1c gui=bold
    hi LineNr guifg=#585858 guibg=#1c1c1c gui=none

  elseif &t_Co == 256

    hi Normal ctermfg=255 ctermbg=235 cterm=none
    hi Statement ctermfg=255 ctermbg=235 cterm=bold

    hi Comment ctermfg=246 ctermbg=235 cterm=none
    hi SpecialComment ctermfg=246 ctermbg=235 cterm=bold

    hi Todo ctermfg=235 ctermbg=179 cterm=none

    hi Constant ctermfg=185 ctermbg=235 cterm=none
    hi PreProc ctermfg=185 ctermbg=235 cterm=none

    hi Type ctermfg=153 ctermbg=235 cterm=none

    hi Special ctermfg=81 ctermbg=235 cterm=none

    hi CursorLine ctermfg=none ctermbg=234 cterm=none
    hi CursorLineNr ctermfg=246 ctermbg=234 cterm=bold
    hi LineNr ctermfg=240 ctermbg=234 cterm=none

  else  " 8-bit color terminal

    hi Normal ctermfg=Grey ctermbg=Black cterm=none
    hi Comment ctermfg=DarkGrey ctermbg=Black cterm=none
    hi SpecialComment ctermfg=DarkGrey ctermbg=Black cterm=bold

  endif

else  " is light

  if has("gui_running")

    hi Normal guifg=#080808 guibg=#eeeeee gui=none
    hi Statement guifg=#080808 guibg=#eeeeee gui=bold

    hi Comment guifg=#808080 guibg=#eeeeee gui=none
    hi SpecialComment guifg=#808080 guibg=#eeeeee gui=bold

    hi Todo guifg=#808080 guibg=#ffff5f gui=none

    hi Constant guifg=#005f00 guibg=#eeeeee gui=none
    hi PreProc guifg=#005f00 guibg=#eeeeee gui=none

    hi Type guifg=#005faf guibg=#eeeeee gui=none

    hi Special guifg=#af5f00 guibg=#eeeeee gui=none

    hi CursorLine guibg=#e4e4e4 gui=none
    hi CursorLineNr guifg=#808080 guibg=#e4e4e4 cterm=bold
    hi LineNr guifg=#a8a8a8 guibg=#e4e4e4 cterm=none

  elseif &t_Co == 256

    hi Normal ctermfg=232 ctermbg=255 cterm=none
    hi Statement ctermfg=232 ctermbg=255 cterm=bold

    hi Comment ctermfg=244 ctermbg=255 cterm=none
    hi SpecialComment ctermfg=244 ctermbg=255 cterm=bold

    hi Todo ctermfg=244 ctermbg=227 cterm=none

    hi Constant ctermfg=22 ctermbg=255 cterm=none
    hi PreProc ctermfg=22 ctermbg=255 cterm=none

    hi Type ctermfg=25 ctermbg=255 cterm=none

    hi Special ctermfg=130 ctermbg=255 cterm=none

    hi CursorLine ctermfg=none ctermbg=254 cterm=none
    hi CursorLineNr ctermfg=244 ctermbg=254 cterm=bold
    hi LineNr ctermfg=248 ctermbg=254 cterm=none

  else  " 8-bit color terminal
  endif
endif
hi! link ColorColumn CursorLine
hi! link Identifier Normal
