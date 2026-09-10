{
  lib,
  fetchFromGitHub,
  jre,
  maven,
  makeWrapper,
  system,
}:
maven.buildMavenPackage rec {
  pname = "openapi-generator-cli";
  # Versioning based on the branch name for clarity.
  # You could use a date or commit hash if preferred.
  version = "v7.26.0-SNAPSHOT";

  src = fetchFromGitHub {
    owner = "OpenAPITools";
    repo = "openapi-generator";
    # Fetch the specific branch
    # tag = "${version}";
    rev = "2ebcc6c700a2c8e658b25a2e58e1d7145333dff8";
    sha256 = "sha256-RyIGgk0IPFH4SSHTdmLyEj8l9qS2jc1XzOiloGXpmD0=";
  };

  patches = [
    # Achieve reproducible mvnHash by pinning develocity plugin.
    # (fetchpatch {
    #   url = "https://github.com/OpenAPITools/openapi-generator/commit/ff66e1bc7fe33dcee89de7296eb7bcd5e2a11cc6.patch";
    #   hash = "sha256-E1VgtaIW1V+8ch2RpW850fVNl5Iqitjog+0b8DKFgZw=";
    # })
    ./develocity-pinned.patch
  ];
  mvnParameters = toString [
    "-Ddevelocity.cache.local.enabled=false"
    "-Ddevelocity.cache.remote.enabled=false"
    # You might also want to disable build scan publishing explicitly, although cache is the primary issue here
    # "-Ddevelocity.scan.uploadInBackground=false"
    # The original derivation used -DskipTests, which is often needed
    "-DskipTests=true"
    "-Duser.home=$TMPDIR"
  ];

  doCheck = false;

  mvnHash = "sha256-P+zAnXcnl0vdAlwbesPbB+w5gwYe1IMiGLAOIF9CJ2c=";

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
