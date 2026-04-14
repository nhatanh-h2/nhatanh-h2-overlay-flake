{ callPackage }:
callPackage ./binary.nix {
  version = "1.24.13";
  hashes = {
    # from https://go.dev/dl/?mode=json&include=all
    darwin-arm64 = "f282d882c3353485e2fc6c634606d85caf36e855167d59b996dbeae19fa7629a";
    linux-amd64 = "1fc94b57134d51669c72173ad5d49fd62afb0f1db9bf3f798fd98ee423f8d730";
  };
}
