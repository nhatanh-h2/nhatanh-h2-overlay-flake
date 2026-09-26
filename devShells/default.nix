{
  pkgs,
}:
let
  # Wraps a shell derivation with `withPackages` / `withoutPackages` helpers so consumers can write
  #   shell.withPackages [ pkgs.cachix ]
  #   shell.withPackages (pkgs: [ pkgs.cachix ])   # pkgs here is the overlaid nixpkgs
  #   shell.withoutPackages (pkgs: [ pkgs.sea-orm-cli-fixed ])
  # instead of spelling out the `overrideAttrs` dance. The result is wrapped again,
  # so calls can be chained.
  withHelpers =
    shell:
    let
      resolve = packages: if builtins.isFunction packages then packages pkgs else packages;
    in
    shell
    // {
      withPackages =
        extraPackages:
        withHelpers (
          shell.overrideAttrs (old: {
            buildInputs = old.buildInputs or [ ] ++ resolve extraPackages;
          })
        );

      # Packages are matched by their store path, so the exact derivation used by the
      # shell has to be passed (e.g. `pkgs.sea-orm-cli-fixed` from the overlaid nixpkgs).
      withoutPackages =
        removedPackages:
        let
          removedPaths = map (p: p.outPath) (resolve removedPackages);
          keep = p: !(builtins.elem (p.outPath or null) removedPaths);
        in
        withHelpers (
          shell.overrideAttrs (old: {
            buildInputs = builtins.filter keep (old.buildInputs or [ ]);
            nativeBuildInputs = builtins.filter keep (old.nativeBuildInputs or [ ]);
          })
        );
    };

  mkShell = args: withHelpers (pkgs.mkShell args);
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
