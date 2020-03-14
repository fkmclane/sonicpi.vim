# vim-sonicpi

The Sonic Pi (Neo)Vim plugin requires the following:

* An installation of [Sonic Pi 2.4+](http://www.sonic-pi.net/).
* A tool to interface with Sonic Pi. The default is [sonic-pi-tool](https://github.com/fkmclane/sonic-pi-tool/).

Either Neovim or Vim 8.1+ is required for log, built-in server, and recording support but older versions of Vim should gracefully fallback to basic functionality.


## Features

The plugin enables itself when Sonic Pi is running and the Ruby filetype is initiated (`let g:sonicpi_enabled = 0` to disable), and provides the following features:

* `<leader>r` - Send buffer to Sonic Pi and show log (`let g:sonicpi_log_enabled = 0` to disable automatic log popout)
* `<leader>c` - Close log output (`let g:sonicpi_log_enabled = 0` to disable automatic log popout)
* `<leader>S` - Send stop message to Sonic Pi
* Contextual autocompletion of Sonic Pi terms with omnicomplete (`<C-x><C-o>` by default). That is, if you have `synth :zawa,` in the line, omnicomplete will provide parameter names for `:zawa`, et al!
* Extension of Ruby syntax to include Sonic Pi terms
* Starting and stopping Sonic Pi server via `:SonicPiServerStart` and `:SonicPiServerStop`
* Recording a Sonic Pi session via `:SonicPiRecord <filename>` and `:SonicPiRecordStop`


## Commands

* `SonicPiSendBuffer` - Send current buffer to Sonic Pi
* `SonicPiStop` - Send Sonic Pi the stop signal
* `SonicPiShowLog` - Pop out the Sonic Pi server log on the right side of the tab page (requires either Neovim or Vim 8 with `terminal` feature)
* `SonicPiCloseLog` - Close the Sonic Pi server log on the current tag page
* `SonicPiCloseAll` - Close all Sonic Pi server log windows
* `SonicPiServerStart` - Start Sonic Pi server using sonic-pi-tool (requires Neovim or Vim 8 with `job` feature)
* `SonicPiServerStop` - Stop Sonic Pi server when managed from (Neo)Vim
* `SonicPiRecord <filename>` - Start a recording to `<filename>` (this will be automatically stopped and saved when stopped or when (Neo)Vim is closed) (requires Neovim or Vim 8 with `job` and `channel` features)
* `SonicPiRecordStop` - Stop the current recording and save it to the previously specified filename


## Installation

Prerequisites: [Sonic Pi 2.4+](http://www.sonic-pi.net/) and [sonic-pi-tool](https://github.com/fkmclane/sonic-pi-tool/) or similar.

* [vim-plug](https://github.com/junegunn/vim-plug)
  * `Plug 'fkmclane/vim-sonicpi'`
* [Vim 8 packages](http://vimhelp.appspot.com/repeat.txt.html#packages)
  * `git clone https://github.com/fkmclane/vim-sonicpi.git ~/.vim/pack/plugins/start/vim-sonicpi`
* [Pathogen](https://github.com/tpope/vim-pathogen)
  * `git clone https://github.com/fkmclane/vim-sonicpi.git ~/.vim/bundle/vim-sonicpi`
* [Vundle](https://github.com/VundleVim/Vundle.vim)
  * `Plugin 'fkmclane/vim-sonicpi'`

Whenever Sonic Pi is running and you haven't disabled the `g:sonicpi_enabled` flag in your configs, the plugin will activate. The plugin will additionally activate after the server has been started within (Neo)Vim. Otherwise, it's a normal Ruby session!


## Configuration

* `g:sonicpi_command` - Command to use for Sonic Pi interfacing (default: 'sonic-pi-tool')
* `g:sonicpi_check` - Subcommand to use for checking whether Sonic Pi is running (default: 'check')
* `g:sonicpi_run` - Subcommand to use for starting a standalone server (default: 'start-server')
* `g:sonicpi_send` - Subcommand to use for sending stdin to Sonic Pi (default: 'eval-stdin')
* `g:sonicpi_logs` - Subcommand to use for following log output (default: 'logs')
* `g:sonicpi_record` - Subcommand to use for starting a recording (must accept `filename` as the only parameter) (default: 'record')
* `g:sonicpi_stop` - Subcommand to use to give Sonic Pi the stop command (default: 'stop')
* `g:vim_redraw` - Whether to redraw after sending stop command or when activating the plugin after load (default: 0)
* `g:sonicpi_enabled` - Whether vim-sonicpi is enabled (default: 1)
* `g:sonicpi_log_enabled` - Whether automatic log popouts are enabled (default: 1)
* `g:sonicpi_keymaps_enabled` - Whether default keybindings are enabled (default: 1)

As an example, to use [`sonic-pi-cli`](https://github.com/Widdershin/sonic-pi-cli/) the following `.vimrc` or `init.vim` settings would work:

```vim
let g:sonicpi_command = 'sonic_pi'
let g:sonicpi_check = 'version'
let g:sonicpi_send = ''
let g:sonicpi_stop = 'stop'
" Disabled due to lack of support
let g:sonicpi_run = ''
let g:sonicpi_logs = ''
let g:sonicpi_record = ''
```


## Sonic Pi interfacing tools

* [sonic-pi-tool](https://github.com/fkmclane/sonic-pi-tool/). Written in Rust and supports all of the functionality of vim-sonicpi.
* [sonic-pi-cli](https://github.com/Widdershin/sonic-pi-cli/). Written in Ruby but does not support showing the log, starting a standalone server from (Neo)Vim, or initiating recordings.


## TODO

* Add named notes (e.g., `:c4`, `:e2`) and chords (e.g., `sus4`, `m7+5`)
* Add oddball contexts beyond the sounds. For instance, we've added the "spread" context to include `rotate:`
