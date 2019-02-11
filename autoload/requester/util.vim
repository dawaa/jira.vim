let s:Prelude = vital#jv#import('Prelude')
let s:HTTP = vital#jv#import('Web.HTTP')

function! s:_postdata(data) abort
  if s:Prelude.is_dict(a:data)
    return [s:HTTP.encodeURI(a:data)]
  elseif s:Prelude.is_list(a:data)
    return a:data
  else
    return split(a:data, "\n")
  endif
endfunction

function! requester#util#_postdata(data) abort
    return s:_postdata(data)
endfunction

function! requester#util#_create_config(config) abort
    let clients = requester#client#clients()
    let options = {
    \     'method': 'GET',
    \     'headers': {},
    \     'client': clients,
    \     'maxRedirect': 20,
    \     'retry': 1,
    \ }

    let config = copy(a:config)

    if len(config) == 0
        throw 'jira.vim: is missing critical options'
    endif

    if s:Prelude.is_dict(config[-1])
        call extend(options, remove(config, -1))
    endif

    if !has_key(options, 'url')
        throw 'jira.vim: is missing the `url`-property'
    endif

    let options.method = toupper(options.method)

    if has_key(options, 'contentType')
        let options.headers['Content-Type'] = options.contentType
    endif

    if has_key(options, 'param')
        if s:Prelude.is_dict(options.param)
            let getdatastr = s:HTTP.encodeURI(options.param)
        else
            let getdatastr = options.param
        endif

        if strlen(getdatastr)
            let options.url .= '?' . getdatastr
        endif
    endif

    if has_key(options, 'data')
        let options.data = s:_postdata(options.data)
        let options.headers['Content-Length'] = len(join(options.data, "\n"))
    endif

    let options._file = {}

    return options
endfunction
