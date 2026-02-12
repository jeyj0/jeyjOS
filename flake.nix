{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem
      (system:
        let
          nixpkgs-params = {
            inherit system;
            config = { allowUnfree = true; };
          };

          pkgs = import nixpkgs nixpkgs-params;
        in {
          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [ pkgs.bashInteractive ];
            buildInputs = with pkgs; [
              # useful dev-tools
              cosign
            ];
            shellHook = with pkgs; ''
              export DOCKER_BUILDKIT=1
            '';
          };
        }
      );
}
