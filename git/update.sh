#!/bin/bash

# run each build task with a certain nice value
NICENESS=10
FORCE=false
CLEAN=false

while getopts ":fcn:" opt; do
	case ${opt} in
		f )
			FORCE=true
			;;
		n )
			NICENESS=$OPTARG
			;;
		c )
			CLEAN=true
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

	OUT_OF_DATE=false;
	if [ $LOCAL != $REMOTE ]; then
		OUT_OF_DATE=true;
	fi

	if [ $OUT_OF_DATE = true ]; then
		echo "$NAME is out-of-date. Changes:"
		git log --decorate --oneline @{u} ..HEAD
	elif [ $FORCE = true ]; then
		echo "Force build of $NAME"
	else
		echo "$NAME is up-to-date"
		cd ..
		return
	fi

	if [ $OUT_OF_DATE = true ]; then
		git merge @{u} > /dev/null
	fi

	echo "Build $NAME on $TOOLCHAIN: $COMMAND"

	if [ $CLEAN == 1 ]; then
		echo "Cleaning before build"
		$CLEAN_COMMAND
	fi
	rustup default $TOOLCHAIN > /dev/null
	nice -n $NICENESS $COMMAND

	cd ..
}

check_git alacritty nightly "cargo install --path ./alacritty --force" "cargo clean"
check_git rust-analyzer nightly "cargo xtask install" "cargo clean"
check_git bandwhich nightly "cargo install --path . --force" "cargo clean"
check_git dust nightly "cargo install --path . --force" "cargo clean"
check_git fd nightly "cargo install --path . --force" "cargo clean"
check_git grex nightly "cargo install --path . --force" "cargo clean"
check_git hyperfine nightly "cargo install --path . --force" "cargo clean"

#check_git cargo build --release --no-default-features --features "pulseaudio_backend"
