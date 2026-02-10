{
  flake.modules.nixos.base =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      virtualisation = {
        containers.enable = true;
        docker.enable = lib.mkForce false;
        podman = {
          enable = true;
          dockerCompat = true;
          defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
        };
      };

      environment.systemPackages = [
        pkgs.openssl
      ];
      systemd.services.komodo-periphery.serviceConfig.SupplementaryGroups = lib.mkForce [ "podman" ];
      users.users.komodo-periphery.extraGroups = lib.mkForce [ "docker" ];
    };
  flake.modules.nixos.mininas =
    {
      config,
      ...
    }:
    {
      age.secrets."komodo-mininas.toml" = {
        rekeyFile = ./mininas.toml.age;
        owner = config.services.komodo-periphery.user;
        group = config.services.komodo-periphery.group;
      };
      services.komodo-periphery = {
        enable = true;
        configFile = config.age.secrets."komodo-mininas.toml".path;
      };
    };

}
