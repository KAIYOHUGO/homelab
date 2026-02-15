{
  flake.modules.nixos.base =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    {
      networking.firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
        ];
      };
      age.secrets."cloudflare.key" = {
        rekeyFile = ./ssl/cloudflare.key.age;
        owner = "traefik";
        group = config.services.traefik.group;
      };

      services.traefik = {
        enable = true;
        group = "docker";

        staticConfigOptions = {
          api.insecure = true;
          providers.docker = { };
          entryPoints = {
            web = {
              address = ":80";
              http.redirections.entryPoint = {
                to = "websecure";
                scheme = "https";
              };

            };
            websecure = {
              address = ":443";
              http = {
                tls = { };
              };
            };
          };
        };
        dynamicConfigOptions = {
          http.routers = { };
          http.services = { };
          tls = {
            certificates = [
              {
                certFile = ./ssl/cloudflare.cert;
                keyFile = config.age.secrets."cloudflare.key".path;
              }
            ];
          };
        };
      };

    };

}
