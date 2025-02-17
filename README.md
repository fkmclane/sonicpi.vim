# vim-sonic-pi

The Sonic Pi (Neo)Vim plugin requires the following:

* An installation of [Sonic Pi](http://www.sonic-pi.net/) (currently tested against 3.3.1)
* A tool to interface with Sonic Pi - the default is [sonic-pi-tool](https://github.com/emlyn/sonic-pi-tool)
  - Note: I am developing a new tool for v4 due to the major architecture changes - sonic-pi-tool does not (yet) work with Sonic Pi v4

Either Neovim or Vim 8.1+ is required for log, built-in server, and recording support but older versions of Vim should gracefully fallback to basic functionality.


## Features

The plugin enables itself when Sonic Pi is running and the Ruby filetype is initiated (`let g:sonic_pi_enabled = 0` to disable), and provides the following features:

* `<leader>r` - Send the current buffer or selection to Sonic Pi and show log (`let g:sonic_pi_autolog_enabled = 0` to disable automatic log popout)
* `<leader>c` - Close log output (`let g:sonic_pi_autolog_enabled = 0` to disable automatic log popout)
* `<leader>S` - Send stop message to Sonic Pi
* Contextual autocompletion of Sonic Pi terms with omnicomplete (`<C-x><C-o>` by default). That is, if you have `synth :zawa` in the line, omnicomplete will provide parameter names for `:zawa`, and more!
* Extension of Ruby syntax to include Sonic Pi terms
* Starting and stopping Sonic Pi server via `:SonicPiStartServer` and `:SonicPiStopServer`
* Recording a Sonic Pi session via `:SonicPiStartRecording <filename>` and `:SonicPiStopRecording`


## Commands

* `SonicPiEval` - Send current buffer or selection to Sonic Pi
* `SonicPiStop` - Send Sonic Pi the stop signal
* `SonicPiShowLog` - Pop out the Sonic Pi server log on the right side of the tab page (requires either Neovim or Vim 8 with `terminal` feature)
* `SonicPiCloseLog` - Close the Sonic Pi server log on the current tab page
* `SonicPiCloseAll` - Close all Sonic Pi server log windows
* `SonicPiStartServer` - Start Sonic Pi server using sonic-pi-tool (requires Neovim or Vim 8 with `job` feature)
* `SonicPiStopServer` - Stop Sonic Pi server when managed from (Neo)Vim
* `SonicPiCheckServer` - Check if Sonic Pi server is running
* `SonicPiStartRecording <filename>` - Start a recording to `<filename>` (this will be automatically stopped and saved when stopped or when (Neo)Vim is closed) (requires Neovim or Vim 8 with `job` and `channel` features)
* `SonicPiStopRecording` - Stop the current recording and save it to the previously specified filename


## Installation

Prerequisites: [Sonic Pi](http://www.sonic-pi.net/) and [sonic-pi-tool](https://github.com/emlyn/sonic-pi-tool) or similar.

* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'lilyinstarlight/vim-sonic-pi'`
* [Neovim packages](https://neovim.io/doc/user/repeat.html#packages)
  * `git clone https://github.com/lilyinstarlight/vim-sonic-pi.git ~/.local/share/nvim/site/pack/plugins/start/vim-sonic-pi`
* [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  * `git clone https://github.com/lilyinstarlight/vim-sonic-pi.git ~/.vim/pack/plugins/start/vim-sonic-pi`
* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/lilyinstarlight/vim-sonic-pi.git ~/.vim/bundle/vim-sonic-pi`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'lilyinstarlight/vim-sonic-pi'`

Whenever Sonic Pi is running and you haven't disabled the `g:sonic_pi_enabled` flag in your configs, the plugin will activate. The plugin will additionally activate after the server has been started within (Neo)Vim. Otherwise, it's a normal Ruby session!


## Configuration

* `g:sonic_pi_command` - Command to use for Sonic Pi interfacing (default: 'sonic-pi-tool')
* `g:sonic_pi_check` - Subcommand to use for checking whether Sonic Pi is running (default: 'check')
* `g:sonic_pi_run` - Subcommand to use for starting a standalone server (default: 'start-server')
* `g:sonic_pi_run_args` - Arguments to supply to the run subcommand (default: '[]')
* `g:sonic_pi_eval` - Subcommand to use for sending stdin to Sonic Pi (default: 'eval-stdin')
* `g:sonic_pi_stop` - Subcommand to use to give Sonic Pi the stop command (default: 'stop')
* `g:sonic_pi_logs` - Subcommand to use for following log output (default: 'logs')
* `g:sonic_pi_record` - Subcommand to use for starting a recording (must accept `filename` as the only parameter) (default: 'record')
* `g:sonic_pi_enabled` - Whether vim-sonic-pi is enabled (default: 1)
* `g:sonic_pi_autolog_enabled` - Whether automatic log popouts are enabled (default: 1)
* `g:sonic_pi_keymaps_enabled` - Whether default keybindings are enabled (default: 1)
* `g:sonic_pi_log_width` - Width for the log popout (default: 70)

As an example, to use [`sonic-pi-cli`](https://github.com/Widdershin/sonic-pi-cli) the following `.vimrc` or `init.vim` settings would work:

```vim
let g:sonic_pi_command = 'sonic_pi'
let g:sonic_pi_check = 'version'
let g:sonic_pi_eval = ''
let g:sonic_pi_stop = 'stop'
" Disabled due to lack of support
let g:sonic_pi_run = ''
let g:sonic_pi_logs = ''
let g:sonic_pi_record = ''
```


## Sonic Pi Interfacing Tools

* [sonic-pi-tool](https://github.com/emlyn/sonic-pi-tool) (version by [@emlyn](https://github.com/emlyn)) - Written in Python and supports all of the functionality of vim-sonic-pi. This is the preferred tool since it works best with recent Sonic Pi versions and has a few extra handy features that may be incorporated into vim-sonic-pi in the future.
* [sonic-pi-tool](https://github.com/lpil/sonic-pi-tool) (version by [@lpil](https://github.com/lpil)) - Written in Rust and supports all of the functionality of vim-sonic-pi.
* [sonic-pi-cli](https://github.com/Widdershin/sonic-pi-cli) - Written in Ruby but does not support showing the log, starting a standalone server from (Neo)Vim, or initiating recordings.


## To-Do

* Disable autolog if something is already listening on the logs port (e.g. the GUI is up)
* Add more contexts beyond the synths/fx/samples


## Thanks

Many thanks to [@dermusikman](https://github.com/dermusikman) for the sonicpi.vim plugin on which this is based and also to [@samaaron](https://github.com/samaaron) and the whole Sonic Pi community for such an awesome platform!
