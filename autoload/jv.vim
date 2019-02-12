let s:Prelude = vital#jv#import('Prelude')

function! jv#go(...) abort
    let config = get(a:, 1, {})
    return jv#http#request(config)
endfunction

function! jv#bind_fn(fn_name, args) abort
    return function(a:fn_name, a:args)
endfunction

" Taken from
" https://github.com/mnpk/vim-jira-complete/blob/master/autoload/jira.vim#L52
"
" Which in turn, was taken from
" https://github.com/LucHermitte/lh-vim-lib
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

    if s:Prelude.is_dict(issues) && has_key(issues, 'then')
        call issues
            \.then({i -> s:_issues_complete(i)})
    else
        call s:_issues_complete(issues)
    endif

    return ''
endfunction

function! s:_issues_complete(data) abort
    if s:Prelude.is_dict(a:data) && has_key(a:data, 'issues')
        let issues = a:data.issues
    else
        let issues = a:data
    endif

    let issues = map(issues[:], { _, v -> v })
    let format = jv#lh_option_get('jira_completion_format', 'v:val.abbr')
    let line = getline('.')
    call map(issues, "extend(v:val, {'word': ".format."})")
    call filter(issues, 'v:val.abbr =~? line')

    if !empty(issues)
        try
            call lh#icomplete#new(0, issues, '').start_completion()
        catch
            call complete(1, issues)
        endtry
    endif

    return ''
endfunction
