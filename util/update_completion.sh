#!/bin/bash -e

if [ -n "$1" ]; then
	sonic_pi_app_path="$1"
elif [ -e '/Applications/Sonic Pi.app/Contents/Resources/app/server/native/ruby/bin/ruby' ]; then
	sonic_pi_app_path='/Applications/Sonic Pi.app/Contents/Resources/app'
elif [ -e '/opt/sonic-pi/app/server/native/ruby/bin/ruby' ]; then
	sonic_pi_app_path='/opt/sonic-pi/app'
elif [ -e '/usr/lib/sonic-pi/server/native/ruby/bin/ruby' ]; then
	sonic_pi_app_path='/usr/lib/sonic-pi'
else
	echo 'Could not find Sonic Pi' >&2
	exit 1
fi

"$sonic_pi_app_path/server/native/ruby/bin/ruby" --enable-frozen-string-literal -E utf-8 "$(dirname "$0")"/update_completion.rb "$sonic_pi_app_path"
