{
  description = "Overlay flake";

  nixConfig = {
    extra-substituters = "https://nhatanh-h2.cachix.org";
    extra-trusted-public-keys = [
      "nhatanh-h2.cachix.org-1:iNzE+GWK6MCVXo+equPTQj2OCMmclhx6xTakVy3NXbk="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (system: {
      devShells = import ./devShells {
        pkgs = self.outputs.packages.${system}.pkgs;
      };
      overlays.default = nixpkgs.lib.composeExtensions inputs.fenix.overlays.default (import ./overlay.nix);
      packages.pkgs = import nixpkgs {
        inherit system;
        overlays = [ self.outputs.overlays.${system}.default ];
      };
    });
}
