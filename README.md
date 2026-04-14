# Usage
```nix
{
  inputs = {
    h2-overlay = {
      url = "git+ssh://git@github.com/nhatanh-h2/h2-overlay-flake?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      h2-overlay,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ h2-overlay.overlays.default ];
        };
      in
      {
        packages.default = pkgs.mkDerivation {...};
        devShells.default = pkgs.mkShell {...};

        # or using a predefined shell as default
        # devShells.default = h2-overlay.devShells.${system}.goShell;
        # devShells.default = h2-overlay.devShells.${system}.rustShells.stable;
      }
    );
}
```
# Contribution
- Introduce changes via PRs.
- PRs will be merged squash for easier revision tracking in depending repos.
- Changes to the overlay e.g. add, modify or remove a package should stay 1 package per PR.
- Dependencies update should stay 1 input update per PR.
- Changes that can transitively affect other packages should be noted i.e. default compiler version in the overlay.
- Feature implementation/Refactoring/Hotfix/other: anything goes as long as the PR stays focused.
