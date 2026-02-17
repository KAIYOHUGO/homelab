{
  flake.modules.nixos.base =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      virtualisation.docker = {
        enable = true;
      };
      environment.systemPackages = with pkgs; [
        openssl
      ];

      age.secrets."komodo.toml" = {
        rekeyFile = ./komodo.toml.age;
        owner = config.services.komodo-periphery.user;
        group = config.services.komodo-periphery.group;
      };
      networking.firewall.trustedInterfaces = [ "br+" ];
      services.komodo-periphery = {
        enable = true;
        configFile = config.age.secrets."komodo.toml".path;
      };
    };
  flake.modules.nixos.rasp4 =
    { config, ... }:
    {
      networking.firewall = {
        allowedTCPPorts = [
          8120
        ];
      };
    };

}
