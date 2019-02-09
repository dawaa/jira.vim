let s:V = vital#jv#new()
let s:JSON = s:V.import('Web.JSON')

if !exists('s:cached_issues')
  let s:cached_issues = []
endif

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

    if (empty(s:cached_issues) || a:force_update)
        let data = jv#go({
            \ "uri": "/search",
            \ "param": {
                \ "jql": 'assignee="' . user . '"'
            \ }
        \})

        let issues = map(data.issues, { _, v -> s:format_raw_issue(v) })
        let s:cached_issues = issues
    endif

    return s:cached_issues
endfunction
