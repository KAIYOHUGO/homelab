top@{ moduleWithSystem, ... }:
{
  flake.modules.nixos.base = moduleWithSystem (
    { inputs', ... }:
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

      # only need if enable ssl
      # environment.systemPackages = with pkgs; [
      #   openssl
      # ];

      age.secrets."komodo.toml" = {
        rekeyFile = ./komodo.toml.age;
        owner = config.services.komodo-periphery.user;
        group = config.services.komodo-periphery.group;
      };
      networking.firewall.trustedInterfaces = [ "br+" ];
      services.komodo-periphery = {
        enable = true;
        package = inputs'.nixpkgs-stable.legacyPackages.komodo;
        configFile = config.age.secrets."komodo.toml".path;
      };

      services.traefik.dynamicConfigOptions.http = {
        routers.periphery = {
          rule = "Host(`periphery-${config.networking.hostName}.${top.config.homelab.lan-domain}`)";
          service = "periphery";
          entrypoints = [
            "web"
            "websecure"
          ];
          middlewares = [
            "lan-only"
          ];
        };
        services.periphery = {
          loadbalancer.servers = [
            {
              url = "http://localhost:${toString config.services.komodo-periphery.port}";
            }
          ];
        };
      };
    }
  );
}
