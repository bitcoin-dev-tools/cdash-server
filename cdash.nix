{ config, host, ... }:

{
  sops = {
    defaultSopsFile = ./secrets/default.sops.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    gnupg.sshKeyPaths = [ ];
    secrets.cdash-app-key.restartUnits = [ "cdash-init.service" ];
  };

  services.cdash = {
    enable = true;
    hostName = host.domain;
    appUrl = "https://${host.domain}";
    appKeyFile = config.sops.secrets.cdash-app-key.path;
    backupTimeframe = 90 * 24;
    mail.mailer = "log";
  };

  # The CDash module uses nginx for PHP-FPM; Caddy handles public HTTPS.
  services.nginx.virtualHosts.${host.domain}.listen = [
    { addr = "127.0.0.1"; port = 8080; }
  ];

  services.caddy = {
    enable = true;
    virtualHosts.${host.domain}.extraConfig = ''
      reverse_proxy 127.0.0.1:8080
    '';
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
