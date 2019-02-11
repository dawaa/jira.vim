let s:Prelude = vital#jv#import('Prelude')

function! s:_tempname() abort
    return tr(tempname(), '\', '/')
endfunction

function! s:base_command() abort
    if executable('curl')
        return 'curl'
    endif

    throw 'jira.vim: `curl` not found.'
endfunction

function! s:_quoted(str) abort
    let q = (&shellxquote == '"' ?  "'" : '"')
    return q . a:str . q
endfunction

function! s:_add_option(settings, opt, prefix) abort
    if has_key(a:settings, a:opt)
        return [a:prefix, a:settings[a:opt]]
    endif
    return []
endfunction

function! s:_make_header_args(headdata, option) abort
    let args = []
    for [key, value] in items(a:headdata)
        if s:Prelude.is_windows()
            let value = substitute(value, '"', '"""', 'g')
        endif
        call extend(args, [a:option, key . ': ' . value])
    endfor
    return args
endfunction

let s:requester = {}
let s:requester.curl = {}

function! requester#curl#available() abort
    if executable('curl')
        return 1
    endif

    return 0
endfunction

function! requester#curl#new() abort
    return s:requester.curl
endfunction

function! s:requester.curl.create_command(...) abort
    let self.config = requester#util#_create_config(a:000)
    let config = self.config

    let config._file = {
    \     'header': s:_tempname(),
    \     'body': get(config, 'outputFile', s:_tempname()),
    \ }

    let cmd = ['curl']
    call extend(cmd, ['--dump-header', config._file.header])
    call extend(cmd, ['--output', config._file.body])

    if has_key(config, 'data')
        let config._file.post = s:_tempname()
        call writefile(
        \    requester#util#_postdata(config.data),
        \    config._file.post,
        \    'b',
        \)

        call add(cmd, '--data-binary @' . s:_quoted(config._file.post))
    endif

    if has_key(config, 'gzipDecompress')
        \ && config.gzipDecompress
        call add(cmd, '--compressed')
    endif

    call add(cmd, '-L')
    call add(cmd, '-s')
    call add(cmd, '-k')

    call extend(cmd, s:_add_option(config, 'method', '-X'))
    call extend(cmd, s:_add_option(config, 'maxRedirect', '--max-redirs'))
    call extend(cmd, s:_add_option(config, 'timeout', '--max-time'))
    call extend(cmd, s:_add_option(config, 'retry', '--retry'))
    call extend(cmd, s:_make_header_args(config.headers, '-H'))
    call add(cmd, config.url)

    return cmd
endfunction
