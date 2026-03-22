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
      age.secrets."traefik.env" = {
        rekeyFile = ./traefik.env.age;
        owner = "traefik";
        group = config.services.traefik.group;
      };

      services.traefik = {
        enable = true;
        group = "docker";

        staticConfigOptions = {
          api.insecure = true;
          providers.docker = {
            exposedByDefault = false;
          };
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
              http.tls = {
                certResolver = "letsencrypt";
                domains = [
                  {
                    main = "${config.homelab.domain}";
                    sans = [ "*.${config.homelab.domain}" ];
                  }
                  {
                    main = "${config.homelab.lan-domain}";
                    sans = [ "*.${config.homelab.lan-domain}" ];
                  }
                ];
              };
            };
          };
          certificatesResolvers = {
            letsencrypt = {
              acme = {
                storage = "/var/lib/traefik/cert.json";
                # for testing
                # caServer = "https://acme-staging-v02.api.letsencrypt.org/directory";
                dnsChallenge = {
                  provider = "cloudflare";
                };
              };
            };
          };
        };
        dynamicConfigOptions = {
          http = {
            middlewares = {
              lan-only = {
                ipWhiteList = {
                  sourceRange = [
                    # https://en.wikipedia.org/wiki/Private_network
                    "192.168.0.0/16"
                    "fd00::/8"

                    # https://en.wikipedia.org/wiki/Loopback
                    "127.0.0.0/8"
                    "::1/128"
                  ];
                };
              };
            };
          };
          
          tls = {
            certificates = [
              {
                certFile = ./ssl/cloudflare.cert;
                keyFile = config.age.secrets."cloudflare.key".path;
              }
            ];
          };
        };
        environmentFiles = [
          config.age.secrets."traefik.env".path
        ];

      };

    };

}
