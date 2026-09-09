{ callPackage }:
callPackage ./binary.nix {
  version = "1.26.3";
  hashes = {
    # from https://go.dev/dl/?mode=json&include=all
    darwin-arm64 = "875cf54a15311eee2c99b9dd67c68c4a49351d489ab622bf2cfd28c8f2078d3c";
    linux-amd64 = "2b2cfc7148493da5e73981bffbf3353af381d5f93e789c82c79aff64962eb556";
  };
}
