# whole new derivation instead of overriding since it's so short it's not worth the trouble to write a robust override
{
  fetchFromGitHub,
  rustPlatform,
  fetchurl,
}:
let
  owner = "taiki-e";
  version = "0.8.5";
  pname = "cargo-llvm-cov";
  cargoLock = fetchurl {
    name = "Cargo.lock";
    url = "https://crates.io/api/v1/crates/${pname}/${version}/download";
    sha256 = "sha256-RAXJT037wcxk/ODd46XVZrdAOccnmYJah3zK5Srlht0=";
    downloadToTemp = true;
    postFetch = ''
      tar xzf $downloadedFile ${pname}-${version}/Cargo.lock
      mv ${pname}-${version}/Cargo.lock $out
    '';
  };
in
rustPlatform.buildRustPackage {
  inherit pname version;
  src = fetchFromGitHub {
    inherit owner;
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-acd2qauvcVPxDjMuFXkaUxDL4kXoDSCVKDG7ki2pK/Y=";
  };

  postUnpack = ''
    cp ${cargoLock} source/Cargo.lock
  '';

  cargoPatches = [
    ./cargo.patch
  ];
  cargoHash = "sha256-Pn/xc+tn/pwb7YrOzVqN9k1agxTE/UvhVm8Yh8V1kYc=";

  doCheck = false;
  # LLVM_COV = "${llvm}/bin/llvm-cov";
  # LLVM_PROFDATA = "${llvm}/bin/llvm-profdata";

  # nativeCheckInputs = [
  #   git
  # ];

  # # `cargo-llvm-cov` tests rely on `git ls-files.
  # preCheck = ''
  #   git init -b main
  #   git add .
  # '';
}
