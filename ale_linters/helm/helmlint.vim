" Author: Faraaz Khan <faraaz@rationalizeit.us>
" Description: helm lint for Kubernetes helm files
"
" See: https://helm.sh/

call ale#Set('helm_helmlint_options', '')
call ale#Set('helm_helmlint_executable', 'helm')

function! s:GetDir(buffer) abort
  let l:project_root = ale#helm#FindProjectRoot(a:buffer)

  return !empty(l:project_root)
  \   ? l:project_root
  \   : expand('#' . a:buffer . ':p:h')
endfunction

function! ale_linters#helm#helmlint#Handle(buffer, lines) abort
  let l:dir = s:GetDir(a:buffer)
  execute 'echo l:dir'
  "In sample helm lint output below
  " ==> Linting .
  " [INFO] Chart.yaml: icon is recommended
  " [ERROR] templates/deployment.yaml: unable to parse YAML
    "error converting YAML to JSON: yaml: line 4: could not find expected ':'


  " Look for errors i.e. lines like the following:
  "
  " [ERROR] templates/deployment.yaml: unable to parse YAML error converting YAML to JSON: yaml: line 4: could not find expected ':'
  let l:pattern = '\[ERROR\]\s?(.+):\s?(.+)\n?\t?(.+)line\s(\d+):(\d+)?\s?(.+)$'
  let l:output = []

  for l:match in ale#util#GetMatches(a:lines, l:pattern)
  " Error detail from example above should appear like:
  " "unable to parse YAML, error converting
  " YAML to JSON, could not find expected ':'"

    call add(l:output, {
    \ 'filename': ale#path#GetAbsPath(l:dir, l:match[1]),
    \ 'lnum': l:match[4] + 0,
    \ 'col': l:match[5] + 0,
    \ 'type': 'E',
    \ 'text': l:match[2] + ', ' + lmatch[3] + ', ' + lmatch[6],
    \})
  endfor
  return l:output
endfunction

function! ale_linters#helm#helmlint#GetExecutable(buffer) abort
    return ale#Var(a:buffer, 'helm_helmlint_executable')
endfunction

function! ale_linters#helm#helmlint#GetCommand(buffer) abort

  let l:dir = s:GetDir(a:buffer) "Get chart root dir
  let l:cmd = ale#path#CdString(l:dir) "cd to chart root dir

  " Run Helm Lint in Chart Root Dir
  let l:cmd .= ale#Escape(ale#Var(a:buffer, 'helm_helmlint_executable'))
  let l:cmd .= ' lint'
  return l:cmd
endfunction


call ale#linter#Define('helm', {
\   'name': 'helmlint',
\   'executable_callback': 'ale_linters#helm#helmlint#GetExecutable',
\   'command_callback': 'ale_linters#helm#helmlint#GetCommand',
\   'callback': 'ale_linters#helm#helmlint#Handle',
\   'lint_file': 1,
\})

" vim:sw=2

