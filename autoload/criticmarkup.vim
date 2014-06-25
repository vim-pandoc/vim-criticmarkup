function! criticmarkup#Init()
    command! -buffer -nargs=1 -complete=custom,criticmarkup#CriticCompleteFunc 
                \Critic call criticmarkup#Critic("<args>")
endfunction

function! criticmarkup#InjectHighlighting()
    syn region criticAddition start=/{++/ end=/++}/ 
    syn region criticDeletion start=/{--/ end=/--}/
    syn region criticSubstitutionDeletion start=/{\~\~/ end=/.\(\~>\)\@=/
    syn region criticSubstitutionAddition start=/\~>/ end=/\~\~}/
    syn region criticComment start=/{>>/ end=/<<}/
    syn region criticHighlight start=/{==/ end=/==}/

    hi criticAddition guibg=#00ff00 guifg=#101010
    hi criticDeletion guibg=#ff0000 guifg=#ffffff
    hi link criticSubstitutionAddition criticAddition
    hi link criticSubstitutionDeletion criticDeletion
    hi criticComment guibg=#0099FF guifg=#101010
    hi criticHighlight guibg=#ffff00 guifg=#101010
endfunction

function! criticmarkup#Accept()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind == "criticAddition"
        call search("{++", "cb")
        normal d3l
        call search("++}", "c")
        normal d3l
    elseif kind == "criticDeletion"
        call search("{--", "cb")
        "fails at end of line
        exe "normal d/\\(--}\\)\\@<=\\_.\<cr>"
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        exe "normal d/\\(\\~>\\)\\@<=\\_.\<cr>"
        call search('\~\~}', "c")
        exe "normal d/\\(\\~\\~}\\)\\@<=\\_.\<cr>"
    endif
endfunction

function! criticmarkup#Reject()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind == "criticDeletion"
        call search("{--", "cb")
        normal df}
        call search("--}", "c")
        normal d3l
    elseif kind == "criticAddition"
        call search("{++", "cb")
        normal df}
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        normal df>
        call search('\~\~}', "c")
        normal df}
    endif
endfunction

function! criticmarkup#Critic(args)
    if a:args =~ "accept"
        call criticmarkup#Accept()
    elseif a:args =~ "\(reject\|delete\)"
        call criticmarkup#Reject()
    endif
endfunction

function! criticmarkup#CriticCompleteFunc(a, c, p)
    if len(split(a:c, " ", 1)) < 3
        return "accept\nreject\ndelete"
    else
        return ""
    endif
endfunction
