{ oapi-codegen, fetchFromGitHub }:

oapi-codegen.overrideAttrs {
  version = "2.6.0";
  src = fetchFromGitHub {
    owner = "deepmap";
    repo = "oapi-codegen";
    rev = "efb2df3da288461287f23e49716e72025e655bcc";
    hash = "sha256-VUSqwc6TsMhry4BEj9nMkSaKg9PNMYGktwc0CA3yx6c=";
  };
  vendorHash = "sha256-vgSMGi0mnGX/Hwxu/XalIXLCbm/L4CwQfIf7DEJVk1E=";
}
