#!/bin/bash
rsync -avh $HOME/.factorio/mods/ factorio.int.spans.me:/opt/factorio/mods/ --delete --exclude sync.sh --exclude .vscode/ --exclude test-mod/ --exclude debugadapter* --exclude mod-list.json --exclude mod-settings.dat
