{
  flake.modules.nixos.base =
    { config, lib, ... }:
    {
      options.homelab = {
        # ports = lib.mkOption {
        #   type = lib.types.listOf lib.types.int;
        #   default = [];
        # };
        domain = lib.mkOption {
          type = lib.types.str;
        };
      };
      config = {
        homelab.domain = "k9h.uk";
      };
    };

}
