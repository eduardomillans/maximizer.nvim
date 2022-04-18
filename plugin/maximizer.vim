if (!has("nvim-0.6.0"))
    echoerr "maximizer.nvim require at least nvim-0.6.0"
    finish
endif

let g:maximizer = {
            \ "active": v:false,
            \ "wins": [] 
            \ }
