if exists('g:loaded_jv')
    finish
endif
let g:loaded_jv = 1

let s:cpo_save=&cpo
set cpo&vim

inoremap <silent> <plug>(JvComplete)        <c-r>=jv#_complete(0)<cr>
inoremap <silent> <plug>(JvCompleteNoCache) <c-r>=jv#_complete(1)<cr>

command! -nargs=0 JvGetIssuesNoCache call jira#api#get_issues(1)

let &cpo=s:cpo_save
