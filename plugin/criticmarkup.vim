augroup criticmarkup
    au! Filetype pandoc,markdown,mkd,txt call criticmarkup#Init()
    au! Syntax pandoc,markdown,mkd,txt call criticmarkup#InjectHighlighting()
augroup END
