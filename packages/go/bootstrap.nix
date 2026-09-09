{ callPackage }:
callPackage ./binary.nix {
  version = "1.26.3";
  hashes = {
    # from https://go.dev/dl/?mode=json&include=all
    darwin-arm64 = "278d580b32e299fe4a9c990fcf2d02acfe538c7e551a6ee18f9c7164573d2c63";
    linux-amd64 = "2b2cfc7148493da5e73981bffbf3353af381d5f93e789c82c79aff64962eb556";
  };
}
