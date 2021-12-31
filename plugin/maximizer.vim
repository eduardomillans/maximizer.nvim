if exists("g:loaded_maximizer") | finish | endif

let s:save_cpo = &cpo
set cpo&vim

command! Maximizer lua require("maximizer").toggle()

let &cpo = s:save_cpo
unlet s:save_cpo

let g:loaded_maximizer = 1

let g:maximizer = {
            \ "active": v:false,
            \ "wins": [] 
            \ }
