if exists('g:loaded_sonicpi')
  finish
endif
let g:loaded_sonicpi = 1

if !exists('g:sonicpi_command')
  let g:sonicpi_command = 'sonic-pi-tool'
endif

if !exists('g:sonicpi_check')
  let g:sonicpi_check = 'check'
endif

if !exists('g:sonicpi_send')
  let g:sonicpi_send = 'eval-stdin'
endif

if !exists('g:sonicpi_stop')
  let g:sonicpi_stop = 'stop'
endif

if !exists('g:sonicpi_logs')
  let g:sonicpi_logs = 'logs'
endif

if !exists('g:vim_redraw')
  let g:vim_redraw = 0
endif

if !exists('g:sonicpi_enabled')
  let g:sonicpi_enabled = 1
endif

if !exists('g:sonicpi_keymaps_enabled')
  let g:sonicpi_keymaps_enabled = 1
endif

" Contextual initialization modelled after tpope's vim-sonicpi
function! sonicpi#detect()
  " Test if Sonic Pi is available.
  silent execute '! ' . g:sonicpi_command . ' ' . g:sonicpi_check
  if v:shell_error == 0 && expand(&filetype) == 'ruby' && g:sonicpi_enabled
    if g:sonicpi_keymaps_enabled
      call s:load_keymaps()
    endif
    call s:load_autocomplete()
    call s:load_syntax()
  endif
endfunction

augroup sonicpi
  autocmd!
  autocmd BufNewFile,BufReadPost *.rb call sonicpi#detect()
  autocmd FileType           ruby call sonicpi#detect()
  " Not entirely sure this one will be helpful...
  autocmd VimEnter * if expand('<amatch>')=='\v*.rb'|endif
augroup END

" Autocomplete functionality calls Ruby if no sonicpi directives found
function! s:load_autocomplete()
  if exists('&ofu')
    setlocal omnifunc=sonicpicomplete#Complete
    " Enable words from buffer to be autocompleted unless otherwise set
    if !exists('g:rubycomplete_buffer_loading')
      let g:rubycomplete_buffer_loading = 1
    endif
  endif
endfunction

" Extend Ruby syntax to include Sonic Pi terms
function! s:load_syntax()
  runtime! syntax/sonicpi.vim
endfunction

function! s:SonicPiSendBuffer()
  execute 'silent w !' . g:sonicpi_command . ' ' . g:sonicpi_send
endfunction

function! s:SonicPiShowLog()
  if exists(':terminal')
    let cur = winnr()

    if bufwinnr('Sonic Pi Log') > 0
      execute bufwinnr('Sonic Pi Log') . 'wincmd w'
      call feedkeys('G0', 'nx')
      execute cur . ' wincmd w'
      return
    endif

    if bufexists('Sonic Pi Log')
      execute 'belowright vertical 70 split #' . bufnr('Sonic Pi Log')
      call feedkeys('G0', 'nx')
      execute cur . ' wincmd w'
      return
    endif

    belowright vertical 70 new
    setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap

    setlocal nomodifiable
    setlocal nomodified
    setlocal nonumber

    silent file Sonic Pi Log

    if has('nvim')
      let term = 'terminal'
    else
      let term = 'terminal ++curwin'
    endif

    execute term . ' ' . g:sonicpi_command . ' ' . g:sonicpi_logs

    setlocal nonumber

    silent file Sonic Pi Log

    call feedkeys('G0', 'nx')

    execute cur . ' winc w'
  else
    echo "Command ':terminal' not available"
  endif
endfunction

function! s:SonicPiCloseLog()
  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' winc c'
  endif
  if len(win_findbuf(bufnr('Sonic Pi Log'))) <= 0
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:SonicPiStop()
  execute 'silent !' . g:sonicpi_command . ' ' . g:sonicpi_stop
  if g:vim_redraw
    execute ':redraw!'
  endif
endfunction

" Export public API
command! -nargs=0 SonicPiSendBuffer call s:SonicPiSendBuffer()
command! -nargs=0 SonicPiShowLog call s:SonicPiShowLog()
command! -nargs=0 SonicPiCloseLog call s:SonicPiCloseLog()
command! -nargs=0 SonicPiStop call s:SonicPiStop()

" Set keymaps in Normal mode
function! s:load_keymaps()
  if exists(':terminal')
    nnoremap <leader>r :SonicPiSendBuffer<CR>:SonicPiShowLog<CR>
    nnoremap <leader>c :SonicPiCloseLog<CR>
  else
    nnoremap <leader>r :SonicPiSendBuffer<CR>
  endif
  nnoremap <leader>S :SonicPiStop<CR>
endfunction
