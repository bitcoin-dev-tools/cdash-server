{ host, lib, ... }:

{
  boot.loader.grub.enable = true;
  services.qemuGuest.enable = true;

  networking = {
    hostName = host.hostName;
    useNetworkd = true;
    useDHCP = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ];
    };
  };

  systemd.network.networks."10-wan" = host.network;

  users.mutableUsers = false;
  users.users = {
    root.hashedPassword = "!";
  } // lib.mapAttrs (_: keys: {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "!";
    openssh.authorizedKeys.keys = keys;
  }) host.ssh.users;
  # Administrators authenticate with SSH keys and have no passwords.
  security.sudo.wheelNeedsPassword = false;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      AllowUsers = builtins.attrNames host.ssh.users;
      X11Forwarding = false;
    };
  };

  boot.kernel.sysctl = {
    "kernel.kptr_restrict" = 2;
    "kernel.dmesg_restrict" = 1;
  };

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "26.05";
}
