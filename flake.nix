{
  description = "Overlay flake";
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
