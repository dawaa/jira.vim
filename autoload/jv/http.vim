let s:V = vital#jv#new()
let s:HTTP = s:V.import('Web.HTTP')
let s:JSON = s:V.import('Web.JSON')
let s:B64 = s:V.import('Data.Base64')

function! jv#http#request(config) abort
    let method = get(a:config, 'method', 'get')
    let url =
        \ jv#lh_option_get('jira_base_url', '')
        \ .
        \ jv#lh_option_get('jira_api_service', '/rest/api/3')

    let user = jv#lh_option_get('jira_user', '')
    let token = jv#lh_option_get('jira_token', '')
    let encoded_token = s:B64.encode(user . ':' . token)

    let payload = {
        \ "url": url . get(a:config, 'uri', ''),
        \ "method": method,
        \ "headers": {
            \ "Authorization": "Basic " . encoded_token,
        \ }
    \}

    if has_key(a:config, 'param')
        let payload.param = a:config.param
    endif

    if has_key(a:config, 'data')
        let payload.data = a:config.data
    endif

    let response = s:HTTP.request(payload)

    " Update regex to support HTTP2
    let status_line = get(response.header, 0)
    let matched = matchlist(status_line, '^HTTP/[12]\%(\.\d\)\?\s\+\(\d\+\)\s\+\(.*\)')

    if !empty(matched)
        let [status, status_text] = matched[1 : 2]
        let response.status = status - 0
        let response.statusText = status_text
        let response.success = status =~# '^2'
    endif

    return s:JSON.decode(response.content)
endfunction
