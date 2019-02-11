setlocal completeopt+=menuone,noinsert
setlocal iskeyword+=-

autocmd VimEnter * JvGetIssuesNoCache
