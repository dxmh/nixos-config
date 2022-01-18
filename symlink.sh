#!/usr/bin/env sh

find . -name \*.nix -exec basename {} \; | xargs -rtI{} sudo ln -srfv {} /etc/nixos/{}
