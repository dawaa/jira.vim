let s:V = vital#jv#new()
let s:HTTP = s:V.import('Web.HTTP')
let s:JSON = s:V.import('Web.JSON')
let s:B64 = s:V.import('Data.Base64')

function! jv#http#request(config) abort
    let url =
        \ jv#lh_option_get('jira_base_url', '')
        \ .
        \ jv#lh_option_get('jira_api_service', '/rest/api/3')

    let user = jv#lh_option_get('jira_user', '')
    let token = jv#lh_option_get('jira_token', '')
    let encoded_token = s:B64.encode(user . ':' . token)

    let payload = {
        \ "url": url . get(a:config, 'uri', ''),
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

    let payload = extend(a:config, payload)
    let client = requester#client#new(requester#client#get())

    let cmd = client.create_command(payload)

    let promise = jv#process#open(cmd)
        \.then({-> s:_create_response(client.config)})

    return promise
endfunction

function! s:_readfile(file) abort
    if filereadable(a:file)
        return join(readfile(a:file, 'b'), "\n")
    endif
    return ''
endfunction

function! s:_read_header(file) abort
    let headerstr = s:_readfile(a:file)
    let header_chunks = split(headerstr, "\r\n\r\n")
    return split(get(header_chunks, -1, ''), "\r\n")
endfunction

function! s:_create_response(config) abort
    let header = s:_read_header(a:config._file.header)
    let body = s:_readfile(a:config._file.body)

    for file in values(a:config._file)
        if filereadable(file)
            call delete(file)
        endif
    endfor

    let response = {
    \     'header': header,
    \     'content': body,
    \     'status': 0,
    \     'statusText': '',
    \     'success': 0,
    \ }

    if !empty(header)
        " Update regex to support HTTP2
        let status_line = get(header, 0)
        let matched = matchlist(status_line, '^HTTP/[12]\%(\.\d\)\?\s\+\(\d\+\)\s\+\(.*\)')

        if !empty(matched)
            let [status, status_text] = matched[1 : 2]
            let response.status = status - 0
            let response.statusText = status_text
            let response.success = status =~# '^2'
            call remove(header, 0)
        endif
    endif

    return s:JSON.decode(response.content)
endfunction
