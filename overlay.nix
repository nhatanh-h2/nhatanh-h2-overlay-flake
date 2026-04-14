final: prev: {
  oapi-gen-cli-fixed = prev.callPackage ./packages/openapi-generator.nix { };
  sea-orm-cli-fixed = prev.callPackage ./packages/sea-orm-cli.nix { };

  go = prev.callPackage ./packages/go { go = prev.go; };
  go_latest = final.go;
  # buildGoModule should use the go version in the overlay
  buildGoModule = prev.callPackage "${prev.path}/pkgs/build-support/go/module.nix" { };
  buildGoLatestModule = final.buildGoModule;

  oapi-codegen = prev.callPackage ./packages/oapi-codegen-go.nix {
    oapi-codegen = prev.oapi-codegen;
  };
}
