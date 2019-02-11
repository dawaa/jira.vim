let s:V = vital#jv#new()
let s:JSON = s:V.import('Web.JSON')
let s:Prelude = s:V.import('Prelude')

if !exists('s:cached_issues')
  let s:cached_issues = []
endif

let s:_promise = -1

" Function: s:format_raw_issue(issue)
"
" Takes a raw issue from JIRA's REST API and formats
" it into an abbrev.
"
" @return A dictionary representing the abbreviation.
function! s:format_raw_issue(issue) abort
    let dict = printf(
        \ "{'abbr': '%s', 'menu': '%s'}",
        \ a:issue.key,
        \ a:issue.fields.summary,
    \)
    return s:JSON.decode(dict)
endfunction

function! jira#api#get_issues(force_update) abort
    let user = jv#lh_option_get('jira_user', '')

    if s:Prelude.is_dict(s:_promise)
        return s:_promise
    endif

    if (empty(s:cached_issues) || a:force_update)
        let result = jv#go({
            \ "uri": "/search",
            \ "param": {
                \ "jql": 'assignee="' . user . '"'
            \ }
        \})

        call result
            \.then({data -> map(data.issues, {_, v -> s:format_raw_issue(v)})})
            \.then({issues -> execute('let s:cached_issues = issues')})
            \.then({-> s:cached_issues})
            \.finally({-> execute('echo "Fetched JIRA issues.. done"', '')})

        let s:_promise = result
        return result
    endif

    return s:cached_issues
endfunction
