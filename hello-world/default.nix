{ mkDerivation, base, scotty, stdenv }:
mkDerivation {
  pname = "server";
  version = "0.1.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  enableSharedExecutables = false;
  enableSharedLibraries = false;
  enableStaticLibraries = true;
  configureFlags = [ "--ghc-option=-threaded" ];
  executableHaskellDepends = [ base scotty ];
  license = stdenv.lib.licenses.bsd3;
}
