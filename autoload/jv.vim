function! jv#go(...) abort
    let config = get(a:, 1, {})
    return jv#http#request(config)
endfunction

" Taken from
" https://github.com/mnpk/vim-jira-complete/blob/master/autoload/jira.vim#L52
function! jv#lh_option_get(name, default, ...)
    let scope = (a:0 == 1) ? a:1 : 'bg'
    let name = a:name
    let i = 0
    while i != strlen(scope)
        if exists(scope[i].':'.name)
            " \ && (0 != strlen({scope[i]}:{name}))
            " This syntax doesn't work with dictionaries -> !exe
            " return {scope[i]}:{name}
            exe 'return '.scope[i].':'.name
        endif
        let i += 1
    endwhile
    return a:default
endfunction

function! jv#_complete(...) abort
    let issues = jira#api#get_issues(a:0 ? a:1 : 0)
    let issues = map(issues[:], { _, v -> v })
    let format = jv#lh_option_get('jira_completion_format', 'v:val.abbr')
    let line = getline('.')
    call map(issues, "extend(v:val, {'word': ".format."})")
    call filter(issues, 'v:val.abbr =~ line')

    if !empty(issues)
        call complete(1, issues)
    endif

    return ''
endfunction
