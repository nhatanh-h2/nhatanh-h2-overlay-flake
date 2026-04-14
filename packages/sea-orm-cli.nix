{
  sea-orm-cli,
  rustPlatform,
  fetchCrate,
}:
sea-orm-cli.override (
  let
    rp = rustPlatform;
  in
  {
    rustPlatform = rustPlatform // {
      buildRustPackage =
        args:
        rp.buildRustPackage (
          args
          // {
            version = "1.1.19";
            src = fetchCrate {
              inherit (args) pname;
              version = "1.1.19";
              hash = "sha256-dsise5MDhR4pcD3ZWDUzTG0Q4Fg/VdKw2Q59/g6BabA=";
            };
            cargoHash = "sha256-38KIJYwRvVmChGSJwaRRWbb/HPuuTp/qnvXpo3xjRpE=";
          }
        );
    };
  }
)
