function! requester#client#clients() abort
    return ['curl']
endfunction

function! requester#client#new(client) abort
    let fn_name = printf(
    \     'requester#%s#new',
    \     a:client,
    \ )

    try
        return call(fn_name, [])
    catch /:E117: [^:]\+: requester[^#]\+#new/
        throw printf(
        \     'jira.vim: Requester not found: %s',
        \     a:client,
        \ )
    endtry
endfunction

function! requester#client#get() abort
    for client in requester#client#clients()
        if requester#{client}#available()
            return client
        endif
    endfor

    throw 'jira.vim: No clients were found'
endfunction
