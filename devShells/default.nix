{
  pkgs,
}:
let
  # Wraps a shell derivation with a `withPackages` helper so consumers can write
  #   shell.withPackages [ pkgs.cachix ]
  #   shell.withPackages (pkgs: [ pkgs.cachix ])   # pkgs here is the overlaid nixpkgs
  # instead of spelling out the `overrideAttrs` dance. The result is wrapped again,
  # so calls can be chained.
  withPackagesHelper =
    shell:
    shell
    // {
      withPackages =
        extraPackages:
        withPackagesHelper (
          shell.overrideAttrs (old: {
            buildInputs =
              old.buildInputs or [ ]
              ++ (if builtins.isFunction extraPackages then extraPackages pkgs else extraPackages);
          })
        );
    };

  mkShell = args: withPackagesHelper (pkgs.mkShell args);
in
{
  rustShells =
    let
      commonShellHook = ''
        export RUST_TOOLCHAIN=
        export OAPI_GEN_CMD=openapi-generator-cli
      '';

      rustComponents = [
        "cargo"
        "clippy"
        "rust-src"
        "rustc"
        "rustfmt"
      ];

      commonBuildInputs = with pkgs; [
        oapi-gen-cli-fixed
        sea-orm-cli-fixed
        postgresql
        rust-analyzer
        diesel-cli
        grcov
        cargo-edit
        cargo-sort
        cargo-machete
        cargo-llvm-cov
        protobuf
      ];
    in
    {
      nightly = mkShell {
        shellHook = commonShellHook;
        buildInputs =
          with pkgs;
          [
            (fenix.complete.withComponents rustComponents)
          ]
          ++ commonBuildInputs;
      };
      stable = mkShell {
        shellHook = commonShellHook;
        buildInputs =
          with pkgs;
          [
            (fenix.stable.withComponents rustComponents)
          ]
          ++ commonBuildInputs;
      };
    };
  goShell = mkShell {
    buildInputs = with pkgs; [
      go
      gopls
      gotools
      go-tools
      golangci-lint
      protobuf
      oapi-codegen
      sqlc
      gofumpt
    ];
  };
}
