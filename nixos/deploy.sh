#!/usr/bin/env bash
echo "setup experimental features..."

mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" | tee -a ~/.config/nix/nix.conf
