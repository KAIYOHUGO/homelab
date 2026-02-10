{ inputs, self, ... }:
{
  flake.agenix-rekey = inputs.agenix-rekey.configure {
    userFlake = self;
    nixosConfigurations = self.nixosConfigurations;
  };

  perSystem =
    {
      config,
      pkgs,
      inputs',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [ inputs'.agenix-rekey.packages.default ];
      };
    };
  flake.modules.nixos.base =
    {
      config,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.agenix.nixosModules.default
        inputs.agenix-rekey.nixosModules.default
      ];

      age.rekey = {
        storageMode = "local";
        masterIdentities = [ "/home/hugo/.ssh/id_ed25519_agenix" ];
        localStorageDir = ../../.secrets/${config.networking.hostName};
      };
    };
  flake.modules.nixos.mininas =
    { config, ... }:
    {
      age.rekey.hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPGJXex0XbUgq6mp1TXlsvLR1EXlYERyRdwoezn7EcRT";
    };
}
