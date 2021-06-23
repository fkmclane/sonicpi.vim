#!/bin/sh -e

if [ -n "$1" ]; then
	sonic_pi_app_path="$1"
	if [ -n "$2" ]; then
		ruby_exe="$2"
	fi
elif [ -d '/Applications/Sonic Pi.app/Contents/Resources/app' ]; then
	sonic_pi_app_path='/Applications/Sonic Pi.app/Contents/Resources/app'
elif [ -d '/opt/sonic-pi/app' ]; then
	sonic_pi_app_path='/opt/sonic-pi/app'
elif [ -d '/usr/lib/sonic-pi/server' ]; then
	sonic_pi_app_path='/usr/lib/sonic-pi'
elif which sonic-pi >/dev/null 2>&1; then
	sonic_pi_app_path="$(dirname "$(dirname "$(realpath "$(which sonic-pi)")")")"/app
else
	echo 'Could not find Sonic Pi' >&2
	exit 1
fi

if [ -z "$ruby_exe" ]; then
	if [ -x "$sonic_pi_app_path/server/native/ruby/bin/ruby" ]; then
		ruby_exe="$sonic_pi_app_path/server/native/ruby/bin/ruby"
	elif which ruby >/dev/null 2>&1; then
		ruby_exe="$(which ruby)"
	else
		echo 'Could not find Ruby executable' >&2
		exit 2
	fi
fi

"$ruby_exe" --enable-frozen-string-literal -E utf-8 "$(dirname "$0")"/update_completion.rb "$sonic_pi_app_path"
