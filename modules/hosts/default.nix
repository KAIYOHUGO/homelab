{
  inputs,
  config,
  options,
  lib,
  ...
}:
{
  flake.nixosConfigurations =
    let
      mkNixosConfig = name: {
        ${name} = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            inputs.nixpkgs.nixosModules.notDetected
            config.flake.modules.nixos.base
            config.flake.modules.nixos.${name}
            {
              # black magic
              # share global config.homelab into module
              options.homelab = options.homelab;
              config = {
                networking.hostName = name;
                homelab = config.homelab;
              };
            }
          ];
        };
      };
    in
    lib.foldlAttrs (
      acc: name: value:
      acc // mkNixosConfig name
    ) { } config.homelab.servers;
}
