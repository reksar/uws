function! OSname()

	if has('unix')
		let l:uname = system('uname')

    	if l:uname =~ 'Darwin'
				return 'Mac'

    	elseif l:uname =~ 'CYGWIN'
				return 'Cygwin'

			else
				return 'Linux'
			endif

	elseif has('win32')
		return 'Windows'

	else
		return 'Unknown'
	endif
endfunction
