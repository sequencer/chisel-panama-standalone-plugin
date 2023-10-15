{
  description = "panama plugin for chisel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }@inputs:
    let
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          pkgs = import nixpkgs { inherit system; overlays = [ overlay ]; };
          deps = with pkgs; [
            mill
            circt
            clang
            jextract
            cmake
            cmakeCurses
          ];
        in
        {
          legacyPackages = pkgs;
          defaultPackage = (with pkgs; stdenv.mkDerivation {
              pname = "chisel-panama-lib";
              version = "0.1";
              src = ./.;
              nativeBuildInputs = [
                clang
                cmake
                ninja
              ];
              cmakeFlags = [
                "-DCIRCT_DIR=${pkgs.circt}/lib/cmake/circt"
                "-DMLIR_DIR=${pkgs.circt}/lib/cmake/mlir"
                "-DLLVM_DIR=${pkgs.circt}/lib/cmake/llvm"
                "-DBUILD_SHARED_LIBS=ON"
                "-DLLVM_ENABLE_ZSTD=Off"
              ];
            });
          devShell = pkgs.mkShell {
            buildInputs = deps;
            env = {
              CIRCT_INSTALL_PATH = pkgs.circt;
            };
          };
        }
      ) // { inherit inputs; overlays.default = overlay; };
}
