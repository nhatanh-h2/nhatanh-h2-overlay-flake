{ gofumpt, fetchFromGitHub }:

gofumpt.overrideAttrs (
  old: final: {
    version = "0.10.0";
    src = fetchFromGitHub {
      owner = "mvdan";
      repo = "gofumpt";
      rev = "v${final.version}";
      hash = "sha256-ngqg8YJHqW08hvZp+E+RLLjGArOZJov7/xKCMAWFI1E=";
    };
    vendorHash = "sha256-qCXpFxTZIhDDvvwytvftBnMwOHopO6/FkBWcLZhBDp8=";
  }
)
