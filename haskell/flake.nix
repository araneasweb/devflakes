{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { nixpkgs, ... }:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system:
          f {
            pkgs = import nixpkgs { inherit system; };
          });

      mkProject = pkgs:
        let
          haskellPackages =
            pkgs.haskell.packages.ghc9122.override {
              overrides = self: super: {
                sandwich = pkgs.haskell.lib.dontCheck super.sandwich;
              };
            };

          cabalFile =
            builtins.head (builtins.filter
              (name: builtins.match ".*\\.cabal" name != null)
              (builtins.attrNames (builtins.readDir ./.)));

          packageName = builtins.elemAt (builtins.match "(.*)\\.cabal" cabalFile) 0;
          drv = haskellPackages.callCabal2nix packageName ./. { };
        in
        {
          inherit haskellPackages drv packageName cabalFile;
        };
    in
    {
      packages = eachSystem ({ pkgs }:
        let p = mkProject pkgs;
        in {
          default = p.drv;
        });

      devShells = eachSystem ({ pkgs }:
        let
          p = mkProject pkgs;
        in
        {
          default = p.haskellPackages.shellFor {
            packages = _: [ p.drv ];
            withHoogle = true;

            nativeBuildInputs = [
              p.haskellPackages.cabal-install
              pkgs.haskell-language-server
              p.haskellPackages.hlint
              p.haskellPackages.ormolu
              p.haskellPackages.ghcid
            ];

            shellHook = ''
              export HIE_HOOGLE_DATABASE=${p.haskellPackages.ghc}/share/doc/hoogle/index.html
            '';
          };
        });

      apps = eachSystem ({ pkgs }: {
        rename = {
          type = "app";
          program = "${pkgs.writeShellApplication {
            name = "rename-haskell-project";
            runtimeInputs = [
              pkgs.coreutils
              pkgs.findutils
              pkgs.gnused
              pkgs.gawk
            ];
            text = /* bash */ ''
              set -euo pipefail
              new_name="''${1:?usage: nix run .#rename -- <project-name>}"
              to_pascal() {
                printf '%s\n' "$1" | awk '
                                BEGIN { FS = "-"; OFS = "" }
                                {
                                  for (i = 1; i <= NF; i++) {
                                    $i = toupper(substr($i, 1, 1)) substr($i, 2)
                                  }
                                  print
                                }
                              '
              }
              cabal_file="$(find . -maxdepth 1 -name '*.cabal' | head -n1)"
              old_file="$(basename "$cabal_file")"
              old_name="''${old_file%.cabal}"
              old_module="Template"
              new_module="$(to_pascal "$new_name")"
              mv "$old_file" "$new_name.cabal"
              sed -i \
                -e "s/^name:.*/name: $new_name/" \
                -e "s/^executable $old_name$/executable $new_name/" \
                -e "s/^test-suite $old_name-test$/test-suite $new_name-test/" \
                -e "s/^\\([[:space:]]*\\)$old_name\\([[:space:]]*,\\)\\?$/\\1$new_name\\2/" \
                -e "s/^[[:space:]]*$old_module$/    $new_module/" \
                "$new_name.cabal"
              mv "src/$old_module.hs" "src/$new_module.hs"
              sed -i \
                -e "s/^module $old_module /module $new_module /" \
                "src/$new_module.hs"
              sed -i \
                -e "s/^import $old_module /import $new_module /" \
                "app/Main.hs"
              sed -i \
                -e "s/^import $old_module /import $new_module /" \
                "test/Spec.hs"
              echo "$old_name -> $new_name"
              echo "$old_module -> $new_module"
            '';
          }}/bin/rename-haskell-project";
        };
      });
    };
}
