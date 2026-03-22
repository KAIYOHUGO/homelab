{ config, lib, ... }:
{
  options.homelab = {
    domain = lib.mkOption {
      type = lib.types.str;
    };
    lan-domain = lib.mkOption {
      type = lib.types.str;
    };

    # hostname = ip addr
    servers = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };

    # key.${lan-domain} = value(host)
    mappings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
    };

  };
  config.homelab = {
    domain = "k9h.uk";
    lan-domain = "homelab.${config.homelab.domain}";

    servers = {
      rasp4 = "192.168.1.136";
      mininas = "192.168.1.215";
    };
  };
}
