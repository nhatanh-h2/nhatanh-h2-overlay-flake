{
  go,
  iana-etc,
  mailcap,
  tzdata,
  replaceVars,
  buildPackages,
}:
let
  version = "1.26.2";
  goBootstrap = buildPackages.callPackage ./bootstrap.nix { };
in
go.overrideAttrs (old: {
  inherit version;
  src = builtins.fetchurl {
    url = "https://go.dev/dl/go${version}.src.tar.gz";
    sha256 = "sha256:0fyldyyrval29zngyp9pdlxfdvq2i1m95cxjdx1yk5ksjjvfp49f";
  };
  patches = [
    (replaceVars ./iana-etc.patch {
      iana = iana-etc;
    })
    # Patch the mimetype database location which is missing on NixOS.
    # but also allow static binaries built with NixOS to run outside nix
    (replaceVars ./mailcap.patch {
      inherit mailcap;
    })
    # prepend the nix path to the zoneinfo files but also leave the original value for static binaries
    # that run outside a nix server
    (replaceVars ./tzdata.patch {
      inherit tzdata;
    })
    ./remove-tools.patch
    ./go_no_vendor_checks.patch
    ./go-env-go_ldso.patch
  ];
  GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";
})
