{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      eachSystem =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
          system:
          f {
            pkgs = import nixpkgs {
              inherit system;
            };
          }
        );
    in
    {
      devShells = eachSystem (
        { pkgs }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              racket
            ];
            env = { };
            shellHook = /* bash */ ''
              set -euo pipefail
              export PLTUSERHOME="$PWD/.racket"
              export PLTADDONDIR="$PWD/.racket"
              mkdir -p "$PLTUSERHOME"
              raco pkg install --auto --skip-installed \
                fmt fixw rackcheck racket-langserver
            '';
          };
        }
      );
    };
}
