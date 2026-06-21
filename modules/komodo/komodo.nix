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

      # komodo 2 need this
      environment.systemPackages = with pkgs; [
        openssl_3
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
        environment = {
          PERIPHERY_CORE_PUBLIC_KEYS = "file:${./core.pub}";
        };
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
