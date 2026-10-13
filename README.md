# CDash server base OS

NixOS configuration for a CDash server.

- The configuration packages CDash 5.5.2 for `https://cdash.fish.foo` using this repo's [package](pkgs/cdash/default.nix) and [NixOS module](modules/cdash/nixos/default.nix).
- Caddy handles HTTPS and proxies to nginx on `127.0.0.1:8080`. PostgreSQL uses local peer authentication.
- The public firewall opens SSH, HTTP, and HTTPS. Root SSH and password authentication are disabled; `satoshi` has passwordless sudo.

## Administration

Make changes and switch to them using the `justfile`.

Run from this directory:

- `just check` checks the configuration.
- `just build` builds the system locally.
- `just deploy` generates `hardware.nix` and installs with nixos-anywhere.
  **This erases the configured disk, currently `/dev/sda`.** Keep the generated
  file for subsequent updates.
- `just switch` updates the existing server through nixos-rebuild.
- `just switch-remote` syncs the configuration to `~/cdash-server` and runs
  the build and switch there, avoiding local store uploads.

Back up the CDash database before upgrading; NixOS rollback does not undo
its database migrations.

## Deploying to a new server

Before running `just deploy`:

- Set `host` in `justfile` to the new IP. Update its SSH key path if needed;
  the key must allow root access to the fresh server.
- Update `host.nix`: hostname, domain, address, network MAC, IPv6 address/gateway,
  disk, architecture, and administrator public key as needed.
- Add the new server's ED25519 SSH host-key age recipient to `.sops.yaml`, then
  run `sops updatekeys secrets/default.sops.yaml`. The deploy command preserves
  that host key with `--copy-host-keys` so the installed server can decrypt secrets.
- Point the domain's DNS records at the new server.

The configuration assumes BIOS boot. A UEFI server needs corresponding changes
in `configuration.nix` and `disk-config.nix`; hardware generation does not make
those changes automatically.

The current workstation has an SSH configuration error concerning ownership of
its systemd SSH include. Fix that before using `just deploy`, which uses the
normal SSH configuration.

Deployment detects hardware, partitions the disk, and installs a fresh CDash
instance. To retain existing accounts and build history, restore the database,
application data, and original application key from backups.
