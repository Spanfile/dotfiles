#!/bin/bash

# run each build task with a certain nice value
NICENESS=10

check_git () {
	NAME=$1
	TOOLCHAIN=$2
	COMMAND=$3

	cd $NAME

	git remote update > /dev/null
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})

	if [ $LOCAL != $REMOTE ]; then
		echo "$NAME is out-of-date. Changes:"
		git log --decorate --oneline @{u} ..HEAD
		git merge @{u} > /dev/null

		echo "Build $NAME on $TOOLCHAIN: $COMMAND"
		rustup default $TOOLCHAIN > /dev/null
		nice -n $NICENESS $COMMAND
	else
		echo "$NAME is up-to-date"
	fi

	cd ..
}

echo Updating Rust...
rustup update 2>&1 | grep changed

echo Updating Rust tools...
nice -n $NICENESS cargo install-update --all

check_git alacritty stable "cargo install --path ./alacritty --force"
check_git rust-analyzer nightly "cargo xtask install"

#check_git cargo build --release --no-default-features --features "pulseaudio_backend"
