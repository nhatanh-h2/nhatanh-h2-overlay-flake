{ pkgs }:
let
  version = "1.26.2";
in
pkgs.go.overrideAttrs {
  inherit version;
  src = builtins.fetchurl {
    url = "https://go.dev/dl/go${version}.src.tar.gz";
    sha256 = "sha256:0fyldyyrval29zngyp9pdlxfdvq2i1m95cxjdx1yk5ksjjvfp49f";
  };
}
