augroup criticmarkup
    autocmd!
    autocmd Filetype pandoc,markdown,mkd,txt call criticmarkup#Init()
    autocmd Syntax pandoc,markdown,mkd,txt call criticmarkup#InjectHighlighting()
augroup END
