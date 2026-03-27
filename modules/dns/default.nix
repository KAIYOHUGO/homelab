top: {
  flake.modules.nixos.rasp4 =
    { config, lib, ... }:
    {
      networking.firewall = {
        allowedTCPPorts = [
          4000
        ];
        allowedUDPPorts = [
          53
        ];
      };

      services.blocky = {
        enable = true;

        settings = {
          upstreams = {
            groups = {
              default = [
                # 1.1.1.1
                "sdns://AAcAAAAAAAAABzEuMS4xLjE"
                # DOH
                "sdns://AgcAAAAAAAAABzEuMS4xLjEAAAovZG5zLXF1ZXJ5"

                # 1.0.0.1
                "sdns://AAcAAAAAAAAABzEuMC4wLjE"

                # 8.8.8.8
                "sdns://AAcAAAAAAAAABzguOC44Ljg"
              ];
            };
          };
          customDNS = {
            rewrite = {
              "lan" = "";
            };
            mapping =
              let
                mkServer = host: ip: {
                  ${host} = ip;
                  "periphery-${host}.${top.config.homelab.lan-domain}" = ip;
                };
                mkMapping = name: host: {
                  "${name}.${top.config.homelab.lan-domain}" = top.config.homelab.servers.${host};
                };
                mkOverride = name: host: {
                  "${name}.${top.config.homelab.domain}" = top.config.homelab.servers.${host};
                };
              in
              (lib.foldlAttrs (
                acc: name: value:
                acc // mkServer name value
              ) { } top.config.homelab.servers)
              // (lib.foldlAttrs (
                acc: name: value:
                acc // mkMapping name value
              ) { } top.config.homelab.mappings)
              // (lib.foldlAttrs (
                acc: name: value:
                acc // mkOverride name value
              ) { } top.config.homelab.overrides);
          };
          blocking = {
            denylists = {
              ads = [
                "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/wildcard/pro.txt"
                ./smart-tv.host
              ];
            };
            clientGroupsBlock = {
              default = [
                "ads"
              ];
            };

          };
          ports = {
            dns = 53;
            http = 4000;
          };
          queryLog = {
            type = "csv";
            logRetentionDays = 3;
            target = "/var/log/blocky";
          };
        };
      };
    };

}
