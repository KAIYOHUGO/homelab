{ moduleWithSystem, ... }:
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
    }
  );
}
