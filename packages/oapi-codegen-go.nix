{ oapi-codegen, fetchFromGitHub }:

oapi-codegen.overrideAttrs {
  version = "v2.8.0";
  src = fetchFromGitHub {
    owner = "oapi-codegen";
    repo = "oapi-codegen";
    rev = "de2d8b2b0afb287198554eb305bb0d2687d26a85";
    hash = "sha256-CrHseuO3gNFTJgP9b8Tec7qJ/jvmKgm3ZwiMBrAcIq8=";
  };
  vendorHash = "sha256-Oom7OcyWv+iXDb1AUsHXJ74eMYN9L7InrNuq4pfggYA=";
}
