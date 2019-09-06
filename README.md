# vim-ramda-import

This is a plugin to make easier to import ramda's functions while writing code.

## Usage

It's really simple to use this plugin, just add a mapping to the function `ImportFunction`, like this:
```vim
nnoremap <C-i> :call ImportFunction()<CR>
```
The code above will map the automatic import to the `CTRL+i`, so when you press it with cursor under the function's name
that function will be imported.

## Customization

The function import is based on a list to know what are the ramda's functions. If you need for some reason to add a function
that doesn't exist in that list, you can edit the `g:ramdaFunctionsList` like this:
```vim
" This will add `merge` (that is a deprecated function) to the functions list
let g:ramdaFunctionsList = add(g:ramdaFunctionsList, 'merge')
```
