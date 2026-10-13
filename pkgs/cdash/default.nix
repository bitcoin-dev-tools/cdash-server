{
  lib,
  fetchFromGitHub,
  buildNpmPackage,
  nodejs_24,
  php84,
}:
let
  version = "5.5.2";
  src = fetchFromGitHub {
    owner = "Kitware";
    repo = "CDash";
    tag = "v${version}";
    hash = "sha256-lYGRFhnF16m1U7AQQA+ZlV7nfeHDunpfwIDPSdGpMmE=";
  };
  php = php84.buildEnv {
    extensions =
      { enabled, all }:
      enabled
      ++ (with all; [
        bcmath
        bz2
        gd
        ldap
        pdo_pgsql
        xsl
      ]);
  };
  frontend = buildNpmPackage {
    pname = "cdash-frontend";
    inherit version src;
    nodejs = nodejs_24;
    npmDepsHash = "sha256-pE93sQUhhLM2EyOiRZTRxx3GqzE/seoLXlrI3JKSjK4=";
    npmFlags = [ "--omit=dev" ];
    npmBuildScript = "prod";
    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r public/. $out/
      runHook postInstall
    '';
  };
in
php.buildComposerProject2 {
  pname = "cdash";
  inherit version src;
  vendorHash = "sha256-NMvyKcqsGqapUb1I7kFuwugsk/cDZRF8gMDIzKpD2UY=";
  postBuild = ''
    cp -r ${frontend}/. public/
    printf 'v${version}\n' > public/VERSION
  '';
  postInstall = ''
    rm -rf $out/share/php/cdash/{tests,docker,.github}
  '';
  passthru.phpPackage = php;
  meta = {
    description = "Web dashboard for CTest build and test results";
    homepage = "https://www.cdash.org";
    license = lib.licenses.bsd3;
  };
}
