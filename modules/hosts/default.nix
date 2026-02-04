{
  inputs,
  config,
  pkgs,
  ...
}:
{
  flake.nixosConfigurations =
    let
      mkNixosConfig = name: sys: {
        ${name} = inputs.nixpkgs.lib.nixosSystem {
          modules = [
            inputs.nixpkgs.nixosModules.notDetected
            config.flake.modules.nixos.base
            config.flake.modules.nixos.${name}
            {
              networking.hostName = "mininas";
            }
          ];
          system = sys;
        };
      };
    in
    (mkNixosConfig "mininas" "x86_64-linux");
}
