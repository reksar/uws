function! MapAutoclose(open, close)
  const map = 'inoremap <expr> '

	if a:open == a:close
		exe map.a:open.' AutocloseTwinChar("'.a:open.'")'
	else
		exe map.a:open.' AutocloseHiralChar("'.a:open.'", "'.a:close.'")'
		exe map.a:close.' PasteOrJump("'.a:close.'")'
	endif
endfunction


function! AutocloseTwinChar(char)
  if s:next_char() == a:char
    return s:move_cursor_right()
  endif
  return AutocloseHiralChar(a:char, a:char)
endfunction


function! AutocloseHiralChar(open, close)
	if s:need_to_close()
		return a:open . a:close . s:move_cursor_left()
	endif
  return a:open
endfunction


function! PasteOrJump(close)
	if s:next_char() == a:close
		return s:move_cursor_right()
	endif
  return a:close
endfunction


function! s:need_to_close()
	const next = s:next_char()
	return ((next == '')
  \  || (next =~ '\s')
  \  || (next == '.')
  \  || (next == ';')
  \  || (next == ')')
  \  || (next == ']')
  \  || (next == '}')
  \  || (next == '>')
  \  || (next == "'")
  \  || (next == '"'))
endfunction


function! s:next_char()
	const current_line = getline('.')
	const current_col = col('.')
	const next_col = current_col - 1
	return current_line[next_col]
endfunction


function! s:move_cursor_left()
	const Esc = "\u1B"
	return Esc . 'i'
endfunction


function! s:move_cursor_right()
	const Esc = "\u1B"
	return Esc . 'la'
endfunction


"inoremap <expr> " AutocloseTwinChar('"')
"call MapAutoclose ("(",")")
"call MapAutoclose ("{","}")
"call MapAutoclose ("[","]")
"call MapAutoclose ("'","'")
