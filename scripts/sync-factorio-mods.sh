#!/bin/bash
rsync -avh $HOME/.factorio/mods/ factorio.int.spans.me:/opt/factorio/mods/ --delete --exclude "debugadapter*" --include "*.zip" --exclude "*"
