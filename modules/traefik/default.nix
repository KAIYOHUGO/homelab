top: {
  flake.modules.nixos.base =
    {
      lib,
      config,
      pkgs,
      ...
    }:
    let
      trusted-ips = (
        lib.foldlAttrs
          (
            acc: name: value:
            acc ++ [ value ]
          )
          [
            "127.0.0.1/16"

            # cloudflare
            # Mar 27 2026
            "173.245.48.0/20"
            "103.21.244.0/22"
            "103.22.200.0/22"
            "103.31.4.0/22"
            "141.101.64.0/18"
            "108.162.192.0/18"
            "190.93.240.0/20"
            "188.114.96.0/20"
            "197.234.240.0/22"
            "198.41.128.0/17"
            "162.158.0.0/15"
            "104.16.0.0/13"
            "104.24.0.0/14"
            "172.64.0.0/13"
            "131.0.72.0/22"
            "2400:cb00::/32"
            "2606:4700::/32"
            "2803:f800::/32"
            "2405:b500::/32"
            "2405:8100::/32"
            "2a06:98c0::/29"
            "2c0f:f248::/32"
          ]
          top.config.homelab.servers
      );
    in
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
              forwardedHeaders.trustedIPs = trusted-ips;
              http.redirections.entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
            websecure = {
              address = ":443";
              forwardedHeaders.trustedIPs = trusted-ips;
              http.tls = {
                certResolver = "letsencrypt";
                domains = [
                  {
                    main = "${top.config.homelab.domain}";
                    sans = [ "*.${top.config.homelab.domain}" ];
                  }
                  {
                    main = "${top.config.homelab.lan-domain}";
                    sans = [ "*.${top.config.homelab.lan-domain}" ];
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
