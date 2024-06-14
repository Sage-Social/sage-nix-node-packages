{
  description = "Sage specific NodePackages for Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
        let
            pkgs = import nixpkgs { inherit system; };
            nodeEnv = pkgs.callPackage ./default.nix {};
            packageName = "nodePackages";
        in
        {
            packages.${packageName} = nodeEnv.nodeDependencies;
            defaultPackage = self.packages.${system}.${packageName};
            devShells.default = pkgs.mkShell {
                buildInputs = [ pkgs.nodejs_20 self.packages.${system}.${packageName} pkgs.node2nix];
                shellHook = ''
                echo "Welcome to the development environment for sage-node-pkgs"
                '';
            };
        }
    );
}