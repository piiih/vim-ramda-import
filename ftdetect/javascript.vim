let g:importsList = []

au BufNewFile,BufRead *.js set filetype=javascript
"au BufWrite *.js :call CheckImportedFunctions(g:importsList)
