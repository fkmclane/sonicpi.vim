if exists('g:loaded_sonicpi')
  finish
endif
let g:loaded_sonicpi = 1

if !exists('g:sonic_pi_command')
  let g:sonic_pi_command = 'sonic-pi-tool'
endif

if !exists('g:sonic_pi_check')
  let g:sonic_pi_check = 'check'
endif

if !exists('g:sonic_pi_run')
  let g:sonic_pi_run = 'start-server'
endif

if !exists('g:sonic_pi_eval')
  let g:sonic_pi_eval = 'eval-stdin'
endif

if !exists('g:sonic_pi_stop')
  let g:sonic_pi_stop = 'stop'
endif

if !exists('g:sonic_pi_logs')
  let g:sonic_pi_logs = 'logs'
endif

if !exists('g:sonic_pi_record')
  let g:sonic_pi_record = 'record'
endif

if !exists('g:vim_redraw')
  let g:vim_redraw = 0
endif

if !exists('g:sonic_pi_enabled')
  let g:sonic_pi_enabled = 1
endif

if !exists('g:sonic_pi_autolog_enabled')
  let g:sonic_pi_autolog_enabled = 1
endif

if !exists('g:sonic_pi_keymaps_enabled')
  let g:sonic_pi_keymaps_enabled = 1
endif

let s:server_job = v:null
let s:record_job = v:null

" Contextual initialization
function! sonicpi#detect()
  " Test if Sonic Pi is available.
  if s:SonicPiCheckServer() && expand(&filetype) == 'ruby' && g:sonic_pi_enabled
    if g:sonic_pi_keymaps_enabled
      call s:load_keymaps()
    endif
    call s:load_autocomplete()
    call s:load_syntax()
  endif
endfunction

augroup sonicpi
  autocmd!
  autocmd BufNewFile,BufReadPost *.rb call sonicpi#detect()
  autocmd FileType               ruby call sonicpi#detect()
  autocmd ExitPre                * call s:SonicPiExit()
  " Not entirely sure this one will be helpful...
  autocmd VimEnter               * if expand('<amatch>') == '\v*.rb' | endif
augroup END

" Autocomplete functionality calls Ruby if no Sonic Pi directives found
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

function! s:SonicPiHandleServerExit(job, data, ...)
  let s:server_job = v:null
endfunction

function! s:SonicPiStartServer()
  if g:sonic_pi_run == ''
    echo "No run subcommand defined for '" . g:sonic_pi_command . "'"
    return
  endif

  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:server_job != v:null
    echo 'A server is already running'
    return
  endif

  if has('nvim')
    let s:server_job = jobstart([g:sonic_pi_command, g:sonic_pi_run], {'on_exit': function('s:SonicPiHandleServerExit')})
    if s:server_job <= 0
      s:server_job = v:null
      echo 'Error starting server'
      return
    endif
  else
    let s:server_job = job_start([g:sonic_pi_command, g:sonic_pi_run], {'in_io': 'null', 'out_io': 'null', 'err_io': 'null', 'exit_cb': function('s:SonicPiHandleServerExit')})
    if job_status(s:server_job) != "run"
      s:server_job = v:null
      echo 'Error starting server'
      return
    endif
  endif

  sleep 7

  call sonicpi#detect()

  if g:vim_redraw
    execute 'redraw!'
  endif
endfunction

function! s:SonicPiStopServer()
  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:server_job == v:null
    echo 'There is no running server'
    return
  endif

  if has('nvim')
    call jobstop(s:server_job)
  else
    call job_stop(s:server_job, "int")
  endif
endfunction

function! s:SonicPiCheckServer()
  silent! execute '! ' . g:sonic_pi_command . ' ' . g:sonic_pi_check . ' >/dev/null 2>&1'
  return v:shell_error == 0
endfunction

function! s:SonicPiEval() range
  silent! execute a:firstline . ',' . a:lastline . ' w ! ' . g:sonic_pi_command . ' ' . g:sonic_pi_eval . ' >/dev/null 2>&1'
  if v:shell_error
    echo 'Eval command failed'
    echo "If the file is too large, try using 'run_file' from another buffer"
    return
  endif
endfunction

function! s:SonicPiStop()
  silent! execute '! ' . g:sonic_pi_command . ' ' . g:sonic_pi_stop . ' >/dev/null 2>&1'
  if g:vim_redraw
    execute 'redraw!'
  endif
endfunction

function! s:SonicPiShowLog()
  if g:sonic_pi_logs == ''
    echo "No logs subcommand defined for '" . g:sonic_pi_command . "'"
    return
  endif

  if !has('nvim') && !has('terminal')
    echo "Command ':terminal' not available"
    return
  endif

  let cur = winnr()

  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' wincmd w'
    normal G0
    execute cur . ' wincmd w'
    return
  endif

  if buflisted('Sonic Pi Log')
    execute 'belowright vertical 70 split #' . bufnr('Sonic Pi Log')
    normal G0
    execute cur . ' wincmd w'
    return
  endif

  belowright vertical 70 new
  setlocal buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap

  setlocal nomodifiable
  setlocal nomodified
  setlocal nonumber

  silent! file Sonic Pi Log

  if has('nvim')
    let term = 'terminal'
  else
    let term = 'terminal ++curwin'
  endif

  execute term . ' ' . g:sonic_pi_command . ' ' . g:sonic_pi_logs

  setlocal nonumber

  silent! file Sonic Pi Log

  normal G0

  execute cur . ' wincmd w'
endfunction

function! s:SonicPiCloseLog()
  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' wincmd c'
  endif
  if bufexists('Sonic Pi Log') && len(win_findbuf(bufnr('Sonic Pi Log'))) <= 0
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:SonicPiCloseAll()
  if bufexists('Sonic Pi Log')
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:SonicPiHandleRecordingExit(job, data, ...)
  let s:record_job = v:null
endfunction

function! s:SonicPiStartRecording(fname)
  if g:sonic_pi_record == ''
    echo "No record subcommand defined for '" . g:sonic_pi_command . "'"
    return
  endif

  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:record_job != v:null
    echo 'A recording session is already running'
    return
  endif

  let fname = fnamemodify(expand(a:fname), ':p')

  if has('nvim')
    let s:record_job = jobstart([g:sonic_pi_command, g:sonic_pi_record, fname], {'on_exit': function('s:SonicPiHandleRecordingExit')})
    if s:record_job <= 0
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  else
    let s:record_job = job_start([g:sonic_pi_command, g:sonic_pi_record, fname], {'exit_cb': function('s:SonicPiHandleRecordingExit')})
    if job_status(s:record_job) != "run"
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  endif
endfunction

function! s:SonicPiStopRecording()
  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:record_job == v:null
    echo 'There is no current recording session'
    return
  endif

  if has('nvim')
    call chansend(s:record_job, "\n")
  else
    let chan = job_getchannel(s:record_job)
    call ch_sendraw(job_getchannel(s:record_job), "\n")
  endif
endfunction

function! s:SonicPiExit()
  call s:SonicPiCloseAll()
  if s:record_job != v:null
    call s:SonicPiStopRecording()
  endif
endfunction

" Export public API
command! -nargs=0 SonicPiStartServer call s:SonicPiStartServer()
command! -nargs=0 SonicPiStopServer call s:SonicPiStopServer()
command! -nargs=0 SonicPiCheckServer if s:SonicPiCheckServer() | echo 'Sonic Pi server is running' | else | echo 'Sonic Pi server is NOT running' | endif
command! -nargs=0 -range=% SonicPiEval let view = winsaveview() | <line1>,<line2>call s:SonicPiEval() | call winrestview(view)
command! -nargs=0 SonicPiStop call s:SonicPiStop()
command! -nargs=0 SonicPiShowLog call s:SonicPiShowLog()
command! -nargs=0 SonicPiCloseLog call s:SonicPiCloseLog()
command! -nargs=0 SonicPiCloseAll call s:SonicPiCloseAll()
command! -nargs=1 -complete=file SonicPiStartRecording call s:SonicPiStartRecording(<f-args>)
command! -nargs=0 SonicPiStopRecording call s:SonicPiStopRecording()

" Set keymaps in Normal mode
function! s:load_keymaps()
  if g:sonic_pi_logs != '' && (has('nvim') || has('terminal')) && g:sonic_pi_autolog_enabled
    nnoremap <leader>r :SonicPiShowLog<CR>:SonicPiEval<CR>
    vnoremap <leader>r :<C-U>SonicPiShowLog<CR>:'<,'>SonicPiEval<CR>
    nnoremap <leader>c :SonicPiCloseLog<CR>
  else
    nnoremap <leader>r :SonicPiEval<CR>
    vnoremap <leader>r :SonicPiEval<CR>
  endif
  nnoremap <leader>S :SonicPiStop<CR>
endfunction
