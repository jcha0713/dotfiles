" Syntax file for 99 prompt window
" Highlights #rules in cyan and @files in goldenrod

if exists("b:current_syntax")
  finish
endif

syntax match 99RuleRef /#\S\+/
syntax match 99FileRef /@\S\+/

highlight default 99RuleRef guifg=#00FFFF ctermfg=cyan
highlight default 99FileRef guifg=#DAA520 ctermfg=178

let b:current_syntax = "99prompt"
