# Overview
A while ago, in our BE team at ${CORP}, there was an issue with the derivation for Linh's fork of OpenAPI Generator: on different platforms, the Maven builder in nixpkgs can have different mvnHashes for the vendored dependencies. The fix was simple: just introducing a map from each `${system}` to the corresponding vendor hash.

Nevertheless, it was a pain and also rather error prone to update every repo with this same nix expression, and it's not just this fix either, we need to do this every time we need to update the hashes for OpenAPI Generator, or any other forked and customized dependency we have for that matter.
 There's also a problem with how many packages distribution maintainers (nixpkgs included) haven't been updating Go's compiler and toolchain version as often as we require. The best practice in other organizations using Nix is, we should make an overlay containing every required customization not (currently) present in nixpkgs, and change our existing flakes to make use of that overlay as an input instead so everytime we need to update a customized dependency, we'll just have to update the overlay and bump its version in other repos with a simple nix flake update ${OUR_OVERLAY}.

Another recurring problem is, whenever a new team member is onboarding, especially part timers who also have works and already set up their local environment for those, there's always bound to be some mismatchs between different development contexts, e.g. different versions of the same development tool. There's no "it doesn't work on my machine" anymore if we have standardized development environments that can be exactly reproduced on different local development machines. This is exactly the gateway that draws so many people into nix: hermetic, separate and reproducible development environments with nix shells.

This repository is that overlay plus the standardized development shell derivations, currently just for ${CORP} BE development, but maintainers are open to extend the scope to other engineering contexts (FE, AI, QA, `{DEV,ML}{Sec,Ops}`) too.

## A note on the Cachix substituter
A substituter basically a hash-addressed cache: as every artifact in nix is uniquely identified by the inputs used to build it (which are also artifact in nix), we can address an artifact by the hash of its "ingredients", which is why build products in nix are always prefixed by a hash string. A substituter just takes advantage of this property: if someone already built the derivation and we as the consumer of it already have the hash, we can look it up using that hash in a shared store and "substitute" what we found as the build product, instead of redundantly doing the work all over again. For our usecase, the substituter acts mostly as a binary cache, or maybe similar to a "binary package distribution" that other Linux distros e.g. Debian provide: a builder just builds the packages once, and users of the distro just pull the build products.

Currently the substituter in use is the main maintainer's own Cachix cache which only has limited storage, and the builders are Github's CI runners for aarch64 darwin and x86-64 linux. Cachix is only a temporary choice during the initial, BE-only run of this repository, as our demand expands it's inevitable to migrate to a more scalable choice with a more reasonable price tag, e.g. an [Attic](https://docs.attic.rs) instance with S3 store provisioned by ourselves. Also there's nothing sensitive in the build artifacts produced by this flake at the moment, as it just provides more up-to-date packages and a few very generic dev envs, but in the long run it makes more security sense to have our own cache.
# Usage
```nix
{
  description = "Example flake consuming this overlay flake";

  nixConfig = {
    # Using overlay's substituter (binary cache) to avoid building everything from scratch
    extra-substituters = "https://nhatanh-h2.cachix.org";
    extra-trusted-public-keys = [
      "nhatanh-h2.cachix.org-1:iNzE+GWK6MCVXo+equPTQj2OCMmclhx6xTakVy3NXbk="
    ];
  };

  inputs = {
    nhatanh-h2-overlay = {
      url = "git+ssh://git@github.com/nhatanh-h2/nhatanh-h2-overlay-flake?ref=main";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nhatanh-h2-overlay,
      nixpkgs,
      flake-utils,
      ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ nhatanh-h2-overlay.overlays.${system}.default ];
        };
        # overlaid nixpkgs is also exposed as a package in the flake's output:
        # pkgs = nhatanh-h2-overlay.packages.${system}.pkgs;
      in
      {
        packages.default = pkgs.mkDerivation {...};

        devShells.default = pkgs.mkShell {...};
        # or using one of the predefined shells as default
        # devShells.default = nhatanh-h2-overlay.devShells.${system}.goShell;
        # devShells.default = nhatanh-h2-overlay.devShells.${system}.rustShells.stable;
        # it's also possible to customize your own shell based on a predefined shell,
        # every predefined shell has a `withPackages` helper that appends to its buildInputs:
        # devShells.default = nhatanh-h2-overlay.devShells.${system}.goShell.withPackages [ pkgs.cachix ];
        # it also accepts a function taking the overlaid nixpkgs, and the result can be chained:
        # devShells.default = (nhatanh-h2-overlay.devShells.${system}.goShell.withPackages (pkgs: [ pkgs.cachix ])).withPackages [ pkgs.jq ];
        # or the escape hatch, for anything beyond adding packages:
        # devShells.default = nhatanh-h2-overlay.devShells.${system}.goShell.overrideAttrs (old: { shellHook = old.shellHook + "..."; });
      }
    );
}
```

```sh
$ nix develop
...
do you want to allow configuration setting 'extra-substituters' to be set to '...' (y/N)? # answer y here to use the cache
do you want to allow configuration setting 'extra-trusted-public-keys' to be set to '...' (y/N)? # also answer y here to confirm the public key used to verify content pulled from the cache
```

# Contribution
- Introduce changes via PRs.
- PRs will be merged squash for easier revision tracking in depending repos.
- Changes to the overlay e.g. add, modify or remove a package should stay 1 package per PR.
- Dependencies update should stay 1 input update per PR.
- Changes that can transitively affect other packages should be noted i.e. default compiler version in the overlay.
- Feature implementation/Refactoring/Hotfix/other: anything goes as long as the PR stays focused.
