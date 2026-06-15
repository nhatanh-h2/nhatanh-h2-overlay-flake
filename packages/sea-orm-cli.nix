{
  sea-orm-cli,
  fetchCrate,
  rustPlatform,
}:
sea-orm-cli.overrideAttrs (
  final: old: {
    version = "1.1.20";
    src = fetchCrate {
      pname = old.pname;
      version = "1.1.20";
      hash = "sha256-n7QkCnMF15UMLPPEF093ylzzDESGKKG/q4Y2jvdTcUo=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      name = "${final.pname}-vendor.tar.gz";
      src = final.src;
      hash = "sha256-itn1i2klZeZQIQLF/lqaqTly1QqbtUgZhqHmAzrKn38=";
    };
  }
)
