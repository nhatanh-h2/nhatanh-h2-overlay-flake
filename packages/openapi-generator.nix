{
  lib,
  fetchFromGitHub,
  jre,
  maven,
  makeWrapper,
  system,
}:
let
  # the hash of buildMavenPackage's vendor directory's content can differ depending on the platform
  mvnDepsHashes = {
    "86_64-linux" = "sha256-UDROqsPBACXCVCEdPdjWSFBSB/kfV57uc06Bb1o4GP8=";
    "aarch64-darwin" = "sha256-PiLpJponpJUXakdno+KGxzDvZG6jYRPp3t5q/G5JX+M=";
  };
in
maven.buildMavenPackage rec {
  pname = "openapi-generator-cli";
  # Versioning based on the branch name for clarity.
  # You could use a date or commit hash if preferred.
  version = "master";

  src = fetchFromGitHub {
    owner = "OpenAPITools";
    repo = "openapi-generator";
    # Fetch the specific branch
    rev = "7ce0096e73eccdf33af2e4cb8481efa4ceb0ab3f";
    sha256 = "sha256-AC7mKMsZohsuaQ03b5KZP18Puu9gh4yQMbSPvLWdXN0=";
  };

  mvnParameters = toString [
    "-Ddevelocity.cache.local.enabled=false"
    "-Ddevelocity.cache.remote.enabled=false"
    # You might also want to disable build scan publishing explicitly, although cache is the primary issue here
    # "-Ddevelocity.scan.uploadInBackground=false"
    # The original derivation used -DskipTests, which is often needed
    "-DskipTests=true"
  ];
  mvnHash =
    mvnDepsHashes.${system}
      or (lib.warn "This platform (${system}) doesn't have any known mvnHash for ${pname}" lib.fakeHash);

  # Tools needed on the build machine itself (for wrapper script)
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/openapi-generator-cli
    install -Dm644 modules/openapi-generator-cli/target/openapi-generator-cli.jar $out/share/openapi-generator-cli

    makeWrapper ${jre}/bin/java $out/bin/openapi-generator-cli \
      --add-flags "-jar $out/share/openapi-generator-cli/openapi-generator-cli.jar"
  '';

  # Add some metadata (optional but good practice)
  meta = with lib; {
    description = "OpenAPI Generator CLI tool (linxGnu fork with rust_axum_authorization branch)";
    homepage = "https://github.com/linxGnu/openapi-generator";
    license = licenses.asl20; # Apache License 2.0 (based on upstream)
    maintainers = [ maintainers.your_github_username ]; # Optional: add yourself
    platforms = platforms.unix; # Should work on Linux and macOS
  };
}
