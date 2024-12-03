" Add :W command for saving a file with Linux sudo if no rights for :w!
" Depends on OSname plugin.

if (OSname() == 'Linux')
	command W w !sudo tee %
	an 10.340 &File.Save\ as\ &root<Tab>:W :W<CR>  " Add menu item.
endif

