{
  go,
  iana-etc,
  mailcap,
  tzdata,
  replaceVars,
  buildPackages,
}:
let
  version = "1.27.1";
  goBootstrap = buildPackages.callPackage ./bootstrap.nix { };
in
go.overrideAttrs (
  old:
  {
    inherit version;
    src = builtins.fetchurl {
      url = "https://go.dev/dl/go${version}.src.tar.gz";
      sha256 = "sha256:1c9qn8m8cpxldnw97mhj2g5f7w2l5hzij9s62sv1dn96w6x8lh2f";
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
  }
  # deduplicate overlapping GOROOT_BOOTSTRAP sets
  // (
    let
      # switch on this condition because depending on the nixpkgs revision this would be expected to be set at different place
      isInEnv = (old.env or { }) ? GOROOT_BOOTSTRAP;
    in
    if isInEnv then
      {
        env = builtins.removeAttrs (old.env or { }) [ "GOROOT_BOOTSTRAP" ] // {
          GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";
        };
      }
    else
      {
        env = builtins.removeAttrs (old.env or { }) [ "GOROOT_BOOTSTRAP" ];
        GOROOT_BOOTSTRAP = "${goBootstrap}/share/go";
      }
  )
)
