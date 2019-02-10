let s:Promise = vital#jv#import('Async.Promise')

function! jv#process#async(fn_name, ...) abort
    return s:Promise.new(jv#bind_fn(a:fn_name, a:000))
endfunction
