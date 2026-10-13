host := "46.225.46.115"

# List available recipes.
[private]
default:
    just --list

# Check the configuration without building.
check:
    nix flake check --no-build --all-systems --no-update-lock-file

# Build locally without activation.
build:
    nix build --no-update-lock-file --no-link .#nixosConfigurations.cdash-server.config.system.build.toplevel

# Install a fresh server, erasing /dev/sda.
deploy:
    nix run github:nix-community/nixos-anywhere -- --flake .#cdash-server --generate-hardware-config nixos-generate-config ./hardware.nix -i ~/.ssh/hetzner-temp --copy-host-keys --kexec-extra-flags '--kexec-syscall' --target-host root@{{ host }}

# Build and switch on the server through nixos-rebuild.
switch:
    NIX_SSHOPTS='-F /dev/null -i ~/.ssh/hetzner-temp' nixos-rebuild switch --flake .#cdash-server --build-host satoshi@{{ host }} --target-host satoshi@{{ host }} --no-reexec --no-update-lock-file --sudo

# Sync the configuration, then build and switch entirely remotely.
switch-remote:
    rsync -az --delete --exclude='/.git' --exclude='/result*' -e 'ssh -F /dev/null -i ~/.ssh/hetzner-temp' ./ satoshi@{{ host }}:cdash-server/
    ssh -F /dev/null -i ~/.ssh/hetzner-temp satoshi@{{ host }} 'cd cdash-server && sudo nixos-rebuild switch --flake path:.#cdash-server --no-reexec --no-update-lock-file'
