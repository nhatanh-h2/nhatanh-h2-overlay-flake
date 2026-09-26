{
  sea-orm-cli,
  fetchCrate,
  rustPlatform,
}:
sea-orm-cli.overrideAttrs (
  final: old: {
    version = "2.0.3";
    src = fetchCrate {
      pname = old.pname;
      version = "2.0.3";
      hash = "sha256-cmNpT+UWb8J29fIyYxJ4UB7LdMkFk9EFJOWOV7M2HHI=";
    };
    cargoDeps = rustPlatform.fetchCargoVendor {
      name = "${final.pname}-vendor.tar.gz";
      src = final.src;
      hash = "sha256-ztH9PDN9fYPinBy5TC8TK2DHSvR6koYlec90Y0Mzo28=";
    };
  }
)
