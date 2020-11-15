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
  if s:check_server() && expand(&filetype) == 'ruby' && g:sonic_pi_enabled
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
  autocmd ExitPre                * call s:exit()
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

function! s:handle_server_exit(job, data, ...)
  let s:server_job = v:null
endfunction

function! s:start_server()
  if g:sonic_pi_run == ''
    echo "No run subcommand defined for '" . g:sonic_pi_command . "'"
    return
  endif

  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:server_job != v:null
    echo 'A server is already running in this session'
    return
  endif

  if s:check_server()
    echo 'A server is already running in another session'
    return
  endif

  if has('nvim')
    let s:server_job = jobstart([g:sonic_pi_command, g:sonic_pi_run], {'on_exit': function('s:handle_server_exit')})
    if s:server_job <= 0 || jobwait([s:server_job], 0)[0] != -1
      s:server_job = v:null
      echo 'Error starting server'
      return
    endif
  else
    let s:server_job = job_start([g:sonic_pi_command, g:sonic_pi_run], {'in_io': 'null', 'out_io': 'null', 'err_io': 'null', 'exit_cb': function('s:handle_server_exit')})
    if job_status(s:server_job) != 'run'
      s:server_job = v:null
      echo 'Error starting server'
      return
    endif
  endif

  let time = 0.0
  while time < 10.0 && s:server_job != v:null && !s:check_server()
    sleep 1
    let time += 1.0
  endwhile

  call sonicpi#detect()

  if !s:check_server()
    echo 'Server failed to start'
    return
  endif

  echo 'Server successfully started'
endfunction

function! s:stop_server()
  if !has('nvim') && !(has('job') && has('channel'))
    echo 'Job control not available'
    return
  endif

  if s:server_job == v:null
    echo 'There is no running server in this session'
    return
  endif

  if has('nvim')
    call jobstop(s:server_job)
  else
    call job_stop(s:server_job, 'int')
  endif
endfunction

function! s:check_server()
  call system(g:sonic_pi_command . ' ' . g:sonic_pi_check . ' >/dev/null 2>&1')
  return v:shell_error == 0
endfunction

function! s:eval() range
  call system(g:sonic_pi_command . ' ' . g:sonic_pi_eval . ' >/dev/null 2>&1', join(getline(a:firstline, a:lastline), "\n"))
  if v:shell_error
    echo 'Eval command failed'
    echo "If the file is too large, try using 'run_file' from another buffer"
    return
  endif
endfunction

function! s:stop()
  call system(g:sonic_pi_command . ' ' . g:sonic_pi_stop . ' >/dev/null 2>&1')
endfunction

function! s:show_log()
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

function! s:close_log()
  if bufwinnr('Sonic Pi Log') > 0
    execute bufwinnr('Sonic Pi Log') . ' close!'
  endif
  if bufloaded('Sonic Pi Log') && len(win_findbuf(bufnr('Sonic Pi Log'))) <= 0
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:close_all()
  if bufloaded('Sonic Pi Log')
    execute bufnr('Sonic Pi Log') . ' bdelete!'
  endif
endfunction

function! s:handle_recording_exit(job, data, ...)
  let s:record_job = v:null
endfunction

function! s:start_recording(fname)
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
    let s:record_job = jobstart([g:sonic_pi_command, g:sonic_pi_record, fname], {'on_exit': function('s:handle_recording_exit')})
    if s:record_job <= 0 || jobwait([s:record_job], 0)[0] != -1
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  else
    let s:record_job = job_start([g:sonic_pi_command, g:sonic_pi_record, fname], {'exit_cb': function('s:handle_recording_exit')})
    if job_status(s:record_job) != 'run'
      s:record_job = v:null
      echo 'Error starting recording session'
      return
    endif
  endif
endfunction

function! s:stop_recording()
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

function! s:exit()
  call s:close_all()
  if s:record_job != v:null
    call s:stop_recording()
  endif
endfunction

" Export public API
command! -nargs=0 SonicPiStartServer call s:start_server()
command! -nargs=0 SonicPiStopServer call s:stop_server()
command! -nargs=0 SonicPiCheckServer if s:check_server() | echo 'Sonic Pi server is running' | else | echo 'Sonic Pi server is NOT running' | endif
command! -nargs=0 -range=% SonicPiEval let view = winsaveview() | <line1>,<line2>call s:eval() | call winrestview(view)
command! -nargs=0 SonicPiStop call s:stop()
command! -nargs=0 SonicPiShowLog call s:show_log()
command! -nargs=0 SonicPiCloseLog call s:close_log()
command! -nargs=0 SonicPiCloseAll call s:close_all()
command! -nargs=1 -complete=file SonicPiStartRecording call s:start_recording(<f-args>)
command! -nargs=0 SonicPiStopRecording call s:stop_recording()

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
