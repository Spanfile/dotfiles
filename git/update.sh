#!/bin/bash

check_git () {
	git remote update > /dev/null
	LOCAL=$(git rev-parse @)
	REMOTE=$(git rev-parse @{u})

	if [ $LOCAL != $REMOTE ]; then
		echo "Out-of-date. Changes:"
		git log --decorate --oneline @{u} ..HEAD
		git merge @{u}
		$@
	else
		echo "Up-to-date"
	fi
}

echo Updating Rust...
rustup update

echo Updating Rust tools...
cargo install-update --all

echo Updating Alacritty...
cd alacritty
check_git cargo install --path ./alacritty
cd ..

echo Updating rust-analyzer...
cd rust-analyzer
check_git cargo xtask install
cd ..

#echo Updating coreutils
#cd coreutils
#check_git cargo install --path .
#cd ..

#echo Updating spotifyd...
#cd spotifyd
#check_git cargo build --release --no-default-features --features "pulseaudio_backend"
#cd ..

#echo Updating spotify-tui...
#cd spotify-tui
#check_git cargo build --release
#cd ..
