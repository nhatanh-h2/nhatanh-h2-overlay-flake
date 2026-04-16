{
  pkgs,
}:
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
        protobuf
      ];
    in
    {
      nightly = pkgs.mkShell {
        shellHook = commonShellHook;
        buildInputs =
          with pkgs;
          [
            (fenix.complete.withComponents rustComponents)
          ]
          ++ commonBuildInputs;
      };
      stable = pkgs.mkShell {
        shellHook = commonShellHook;
        buildInputs =
          with pkgs;
          [
            (fenix.stable.withComponents rustComponents)
          ]
          ++ commonBuildInputs;
      };
    };
  goShell = pkgs.mkShell {
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
