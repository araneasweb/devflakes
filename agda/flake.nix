{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
          f {
            pkgs = import nixpkgs {
              inherit system;
            };
          });
    in
    {
      devShells = eachSystem ({ pkgs }: {
        default = pkgs.mkShell {
          packages = with pkgs; [
            (agda.withPackages (p: with p; [
              standard-library
              _1lab
              cubical
              generics
              agdarsec
              agda2hs-base
              agda-prelude
              agda-categories
            ]))
            haskellPackages.agda2hs
          ];
          env = { };
          shellHook = ''
        '';
        };
      });
    };
}
