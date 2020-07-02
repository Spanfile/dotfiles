#!/bin/bash

# run each build task with a certain nice value
NICENESS=10
FORCE=0
CLEAN=0

while getopts ":fcn:" opt; do
	case ${opt} in
		f )
			FORCE=1
			;;
		n )
			NICENESS=$OPTARG
			;;
		c )
			CLEAN=1
			;;
	esac
done

check_git () {
	NAME=$1
	TOOLCHAIN=$2
	COMMAND=$3
	CLEAN_COMMAND=$4

	cd $NAME

	git remote update > /dev/null
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})

	if [ $FORCE == 1 ]; then
		echo "Forcing build of $NAME"

		if [ $CLEAN == 1 ]; then
			echo "Cleaning before build"
			$CLEAN_COMMAND
		fi
		rustup default $TOOLCHAIN > /dev/null
		nice -n $NICENESS $COMMAND
	elif [ $LOCAL != $REMOTE ]; then
		echo "$NAME is out-of-date. Changes:"
		git log --decorate --oneline @{u} ..HEAD
		git merge @{u} > /dev/null

		echo "Build $NAME on $TOOLCHAIN: $COMMAND"

		if [ $CLEAN == 1 ]; then
                        echo "Cleaning before build"
                        $CLEAN_COMMAND
                fi
		rustup default $TOOLCHAIN > /dev/null
		nice -n $NICENESS $COMMAND
	else
		echo "$NAME is up-to-date"
	fi

	cd ..
}

check_git alacritty nightly "cargo install --path ./alacritty --force" "cargo clean"
check_git rust-analyzer nightly "cargo xtask install" "cargo clean"

#check_git cargo build --release --no-default-features --features "pulseaudio_backend"
