jira.vim
====================

Heavily inspired by, [mnpk/vim-jira-complete](https://github.com/mnpk/vim-jira-complete) and [termoshtt/curl.vim](https://github.com/termoshtt/curl.vim).

# Introduction

This plugin was created due to my current work, where we make use of JIRA and tag our commit messages with the issue number the task in JIRA has. Sometimes I forget which one it is, so I have to go back to the JIRA webpage and find my task, which is tedious and JIRA is slow. I much rather have it in Vim anyway.

I plan on adding more functions to fetch data via [JIRA's REST API v3](https://developer.atlassian.com/cloud/jira/platform/rest/v3/), but right now it fetches the JIRA issues assigned to you. Though it does provide an interface using [`jv#go()`](https://github.com/dawaa/jira.vim/blob/master/autoload/jv.vim#L3-L6) if you're feeling adventurous on giving it a go yourself.

## Demo

![normal_completion](https://user-images.githubusercontent.com/2129741/52623210-c4c34c80-2ee6-11e9-8b80-2f263e26caaf.gif)

### With plugin [`lh-vim-lib`](https://github.com/LucHermitte/lh-vim-lib)

In case you have this plugin installed, the following demo below should show you what functionality it brings compared to the built-in one.

![lh_completion](https://user-images.githubusercontent.com/2129741/52623252-ddcbfd80-2ee6-11e9-9385-66d9ac1cbde3.gif)

#### Bugs

I hope to find the time to put up PRs for below issues I've noticed using [`lh-vim-lib`](https://github.com/LucHermitte/lh-vim-lib)

* Fix the cursor-jump issue when no matches are found (note scenario 3 in gif above)
* Allow for case-insensitive matching when calling `lh#icomplete#new()`

# Installation

* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone git://github.com/dawaa/jira.vim.git ~/.vim/bundle/jira.vim`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'dawaa/jira.vim'`

# Instructions

## Prerequisities

Before you can start using this plugin you will have to set the following:

> Make sure to replace what's uppercased in the code snippet below

```vim
let g:jira_base_url = 'https://SITE_NAME.atlassian.net'
let g:jira_user = 'YOUR_EMAIL'
let g:jira_token = 'YOUR_TOKEN'
```

To [generate a token](https://confluence.atlassian.com/cloud/api-tokens-938839638.html), go [here](https://id.atlassian.com) and make sure you log in to the right account that has access to the JIRA you want to generate a token for.
Once logged in, go to [/manage/api-tokens](https://id.atlassian.com/manage/api-tokens) and create a new API token. Copy it and replace `'YOUR_TOKEN'` which you saw earlier with your newly created token.

> It's possible to set up this plugin for multiple JIRA accounts, with the help of [`LucHermitte/local_vimrc`](https://github.com/LucHermitte/local_vimrc).
>
> Follow the instructions in the [`local_vimrc`](https://github.com/LucHermitte/local_vimrc) repo and once you've got your local vimrc up, simply set the variables again but this time, replace `g:` with `b:`, e.g. like so `let b:jira_user = 'YOUR_EMAIL'`.

## Usage

You could invoke the list of JIRA issues by mapping to the mappings the plugin exposes.

> **Don't** use `noremap` if you decide to go with the mappings the plugin provides, because otherwise the mapping won't properly propagate and hit the plugin.

```vim
" These are just example mappings..
"
" <plug>(JvComplete)
" Shows a cached list for completions
imap <C-j> <plug>(JvComplete)

" <plug>(JvCompleteNoCache)
" Refreshes cached list before showing completions
imap <C-f> <plug>(JvCompleteNoCache)
```

or if you fancy calling the update method yourself you could look at calling `:JvGetIssuesNoCache` where or when you wish it to happen.
