{

  perSystem =
    {
      pkgs,
      inputs',
      ...
    }:
    {
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = [
          inputs'.agenix-rekey.packages.default
          pkgs.just
        ];
      };
    };

}
