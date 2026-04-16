{
  sea-orm-cli,
  fetchCrate,
  rustPlatform,
}:
sea-orm-cli.overrideAttrs (
  final: old: {
    version = "1.1.19";
    src = fetchCrate {
      pname = old.pname;
      version = "1.1.19";
      hash = "sha256-dsise5MDhR4pcD3ZWDUzTG0Q4Fg/VdKw2Q59/g6BabA=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      name = "${final.pname}-vendor.tar.gz";
      src = final.src;
      hash = "sha256-38KIJYwRvVmChGSJwaRRWbb/HPuuTp/qnvXpo3xjRpE=";
    };
  }
)
