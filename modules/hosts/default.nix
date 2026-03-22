{
  inputs,
  config,
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
              networking.hostName = name;
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
