{
  description = "Minimal NixOS configuration for a CDash instance";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, disko, sops-nix, ... }:
  let
    host = import ./host.nix;
  in {
    deployment = host;
    nixosConfigurations.cdash-server = nixpkgs.lib.nixosSystem {
      system = host.system;
      specialArgs = { inherit host; };
      modules = [
        disko.nixosModules.disko
        ./modules/cdash/nixos
        sops-nix.nixosModules.sops
        ./hardware.nix
        ./disk-config.nix
        ./configuration.nix
        ./cdash.nix
      ];
    };
  };
}
