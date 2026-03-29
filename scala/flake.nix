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
              openjdk17
              sbt
              scala-cli
              scalafmt
              scalafix
              scala
            ];
            env = { };
            shellHook = ''
              export JAVA_HOME="${pkgs.openjdk17}"
            '';
          };
        }
      );
    };
}
