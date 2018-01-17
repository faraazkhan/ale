" Author: Faraaz Khan <faraaz@rationalizeit.us>
" Description: helm-template for Kubernetes helm files
"
" See: https://helm.sh/
"      https://github.com/technosophos/helm-template

call ale#Set('helm_helmtemplate_options', '')
call ale#Set('helm_helmtemplate_executable', 'helm')

function! ale_linters#helm#helmtemplate#Handle(buffer, lines) abort
    let l:output = []
    return l:output
endfunction

function! ale_linters#helm#helmtemplate#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'helm_helmtemplate_executable')
endfunction

function! ale_linters#helm#helmtemplate#GetCommand(buffer) abort
    let l:cmd = ale#Escape(ale#Var(a:buffer, 'helm_helmtemplate_executable'))

    let l:cmd .= ' template'

    let l:values_file = ale#path#FindNearestFile(a:buffer, 'values.yaml')

    if !empty(l:values_file)
        let l:cmd .= ' -f ' . ale#Escape(l:values_file)
    endif

    let l:opts = ale#Var(a:buffer, 'helm_helmtemplate_options')
    if !empty(l:opts)
        let l:cmd .= ' ' . l:opts
    endif

    let l:cmd .= ' -x %t .'

    return l:cmd
endfunction

call ale#linter#Define('helm', {
\   'name': 'helmtemplate',
\   'executable_callback': 'ale_linters#helm#helmtemplate#GetExecutable',
\   'command_callback': 'ale_linters#helm#helmtemplate#GetCommand',
\   'callback': 'ale_linters#helm#helmtemplate#Handle',
\})

" vim:sw=2
