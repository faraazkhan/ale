" Author: Faraaz Khan <faraaz@rationalizeit.us>
" Description: Functions for integrating with Kubernetes Helm

" Find the nearest dir contining "Chart.yaml", and assume it is
" the root of the chart
function! ale#helm#FindProjectRoot(buffer) abort
    for l:path in ale#path#Upwards(expand('#' . a:buffer . ':p:h'))
        if filereadable(l:path . '/Chart.yaml')
            return l:path
        endif
    endfor

    return ''
endfunction

