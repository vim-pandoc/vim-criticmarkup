function! criticmarkup#Init()
    command! -buffer -nargs=1 -complete=custom,criticmarkup#CriticCompleteFunc 
                \Critic call criticmarkup#Critic("<args>")
endfunction

function! criticmarkup#InjectHighlighting()
    syn region criticAddition matchgroup=criticAdd start=/{++/ end=/++}/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString concealends
    syn region criticDeletion matchgroup=criticDel start=/{--/ end=/--}/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString concealends
    syn region criticSubstitutionDeletion start=/{\~\~/ end=/.\(\~>\)\@=/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString keepend
    syn region criticSubstitutionAddition start=/\~>/ end=/\~\~}/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString keepend
    syn match criticSubstitutionDeletionMark /{\~\~/ contained containedin=criticSubstitutionDeletion conceal
    syn match criticSubstitutionAdditionMark /\~\~}/ contained containedin=criticSubstitutionAddition conceal
    syn region criticComment matchgroup=criticMeta start=/{>>/ end=/<<}/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString concealends
    syn region criticHighlight matchgroup=criticHighlighter start=/{==/ end=/==}/ containedin=pandocAtxHeader,pandocBlockQuote,pandocCodeBlock,pandocFootnoteBlock,pandocListItem,pandocUListItem,pandocDefinitionBlock,pandocYAMLHeader,yamlBlock,yamlHeader,yamlPlainScalar,yamlFlowString concealends

    hi criticAdd guibg=#00ff00 guifg=#101010 ctermbg=10 ctermfg=0
    hi criticDel guibg=#ff0000 guifg=#ffffff ctermbg=9 ctermfg=0
    hi link criticAddition criticAdd
    hi link criticDeletion criticDel
    hi link criticSubstitutionAddition criticAddition
    hi link criticSubstitutionDeletion criticDeletion
    hi link criticSubstitutionAdditionMark criticAddition
    hi link criticSubstitutionDeletionMark criticDeletion
    hi criticMeta guibg=#0099FF guifg=#101010 ctermbg=12 ctermfg=0
    hi criticHighlighter guibg=#ffff00 guifg=#101010 ctermbg=11 ctermfg=0
    hi link criticComment criticMeta
    hi link criticHighlight criticHighlighter
endfunction

function! criticmarkup#Accept()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind =~ "criticAdd"
        call search("{++", "cb")
        normal d3l
        call search("++}", "c")
        normal d3l
    elseif kind =~ "criticDel"
        call search("{--", "cb")
        exe "normal v/\\(--\\)\\@<=}\<cr>"
        normal x
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        exe "normal v/\\~\\@<=>\<cr>"
        normal x
        call search('\~\~}', "c")
        exe "normal d3l"
    endif
endfunction

function! criticmarkup#Reject()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind =~ "criticDel"
        call search("{--", "cb")
        exe "normal v/\\(--\\)\\@<=}\<cr>"
        exe "normal :s/{\\=--}\\=//g\<cr>"
    elseif kind =~ "criticAdd"
        call search("{++", "cb")
        exe "normal v/\\(++\\)\\@<=}\<cr>"
        normal x
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        exe "normal v/.\\(\\~>\\)\\@=\<cr>"
        exe "normal :s/{\\~\\~//g\<cr>"
        call search('\~>', "c")
        exe "normal v/\\(\\~\\~\\)\\@<=}\<cr>"
        normal x
    endif
endfunction

function! criticmarkup#Critic(args)
    if a:args =~ "accept"
        call criticmarkup#Accept()
    elseif a:args =~ "reject"
        call criticmarkup#Reject()
    endif
endfunction

function! criticmarkup#JumpNext(editorial)
	if a:editorial == 1
		exe "normal ".v:count1."/{[-+\\~]\\{2\\}\<CR>"
	else
		exe "normal ".v:count1."/{[-+\\~\>=]\\{2\\}\<CR>"
	endif
endfunction

function! criticmarkup#JumpPrevious(editorial)
	if a:editorial == 1
		exe "normal ".v:count1."?{[-+\\~]\\{2\\}\<CR>"
	else
		exe "normal ".v:count1."?{[-+\\~\>=]\\{2\\}\<CR>"
	endif
endfunction

function! criticmarkup#CriticNext()
	call criticmarkup#JumpNext(1)
    let op = input("What to do? ", "", "custom,criticmarkup#CriticCompleteFunc")
    if op =~ "accept"
        call criticmarkup#Accept()
    elseif op =~ "reject"
        call criticmarkup#Reject()
    endif
endfunction

function! criticmarkup#CriticCompleteFunc(a, c, p)
    if len(split(a:c, " ", 1)) < 3
        return "accept\nreject"
    else
        return ""
    endif
endfunction

nmap ]m :call criticmarkup#JumpNext(0)<CR>
nmap [m :call criticmarkup#JumpPrevious(0)<CR>

nnoremap <buffer> <localleader>ed :set operatorfunc=CMDelOperator<cr>g@
vnoremap <buffer> <localleader>ed :<c-u>call CMOperator(visualmode(),'<','>','{--','--}')<cr>
nnoremap <buffer> <localleader>ea :set operatorfunc=CMAddOperator<cr>g@
vnoremap <buffer> <localleader>ea :<c-u>call CMOperator(visualmode(),'<','>','{++','++}')<cr>
nnoremap <buffer> <localleader>eh :set operatorfunc=CMHilOperator<cr>g@
vnoremap <buffer> <localleader>eh :<c-u>call CMOperator(visualmode(),'<','>','{==','==}')<cr>
nnoremap <buffer> <localleader>ec :set operatorfunc=CMComOperator<cr>g@
vnoremap <buffer> <localleader>ec :<c-u>call CMOperator(visualmode(),'<','>','{>>','<<}')<cr>
nnoremap <buffer> <localleader>es :set operatorfunc=CMSubOperator<cr>g@
vnoremap <buffer> <localleader>es :<c-u>call CMOperator(visualmode(),'<','>','{~~','~>~~}')<cr>

function! CMDelOperator(type)
    call CMOperator(a:type,'[',']','{--','--}')
endfunction

function! CMAddOperator(type)
    call CMOperator(a:type,'[',']','{++','++}')
endfunction

function! CMHilOperator(type)
    call CMOperator(a:type,'[',']','{==','==}')
endfunction

function! CMComOperator(type)
    call CMOperator(a:type,'[',']','{>>','<<}')
endfunction

function! CMSubOperator(type)
    call CMOperator(a:type,'[',']','{~~','~>~~}')
endfunction

function! CMOperator(type, m0, m1, t0, t1)
    let pastem=&paste
    set paste

    if a:type ==# 'v' || a:type == 'char'
        silent exe "normal! `" . a:m0 . "v`" . a:m1 . "d"
        "silent exe "normal! i" . a:t0 . "\<esc>pa" . a:t1 . "\<esc>"
        silent exe "normal! i" . a:t0 . "\<esc>a". a:t1 . "\<esc>g`[P"
    elseif a:type ==# 'V' || a:type == 'line'
        silent exe "normal! `" . a:m0 . "V`" . a:m1 . "d"
        "silent exe "normal! O" . a:t0 . "\<esc>po" . a:t1 . "\<esc>"
        silent exe "normal! O" . a:t0 . "\<cr>" . a:t1 . "\<esc>P"
    endif

    let &paste=pastem
endfunction

