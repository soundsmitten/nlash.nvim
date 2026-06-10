" Vim syntax file
" Language:     prrnotes

if exists("b:current_syntax")
  finish
endif

" Decision metadata
syn match prrnotesDecision "^@\s*review\>\s\+decision\s*=\s*\(approve\|reject\|comment\)\s*$" contains=prrnotesDecisionKey,prrnotesDecisionValue
syn match prrnotesDecisionKey contained "@\s*review\>\|\<decision\>"
syn keyword prrnotesDecisionValue contained approve reject comment

" Shorthand decision lines (# approve / #reject / etc.)
syn match prrnotesDecisionShort "^#\s*\(approve\|reject\|comment\)\s*$" contains=prrnotesDecisionValue

" Regular comment lines
syn match prrnotesComment "^#.*$"

" Note format: file_or_path:line | comment text
syn match prrnotesEntry "^[^#[:space:]][^|]*:[0-9]\+\s*|.*$" contains=prrnotesPath,prrnotesLine,prrnotesSeparator,prrnotesBody
syn match prrnotesPath contained "^[^|:][^|]*\ze:[0-9]\+\s*|"
syn match prrnotesLine contained ":[0-9]\+\ze\s*|"
syn match prrnotesSeparator contained "|"
syn match prrnotesBody contained "|\s*.*$"

hi def link prrnotesDecisionKey Keyword
hi def link prrnotesDecisionValue String
hi def link prrnotesDecisionShort PreProc
hi def link prrnotesComment Comment
hi def link prrnotesPath Directory
hi def link prrnotesLine Number
hi def link prrnotesSeparator Delimiter
hi def link prrnotesBody Normal

let b:current_syntax = "prrnotes"
