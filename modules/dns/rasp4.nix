{
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
                mkMap = host: ip: {
                  "${host}" = ip;
                  "periphery-${host}.${config.homelab.lan-domain}" = ip;
                };
                mkMaps = lib.foldlAttrs (
                  acc: name: value:
                  acc // mkMap name value
                ) {};
              in
              mkMaps {
                rasp4 = "192.168.1.136";
                mininas = "192.168.1.215";
              };
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
