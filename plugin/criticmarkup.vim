augroup criticmarkup
    autocmd!
    autocmd Filetype pandoc,markdown,mkd,txt call criticmarkup#Init()
    autocmd Syntax pandoc,markdown,mkd,txt call criticmarkup#InjectHighlighting()
    " The unorthodox way this plugin injects new syntax rules is broken in
    " Neovim which takes a different approach to initializing the GUI (which
    " is an optional component rather than an assumed part of the system). As
    " a result we don't get initialized at all unless the user happens to
    " set filetype a second time after initial loading or loads a buffer after
    " the GUI is loaded. This hack sidesteps that and makes sure we get a
    " chance to get started. See https://github.com/neovim/neovim/issues/2953
    if has('nvim')
        autocmd VimEnter * doautoa Syntax,Filetype
    endif
augroup END
