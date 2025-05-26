{
  description = "k0s via Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          config.allowUnfree = true; # Allow unfree packages 
        };

        k0s = pkgs.stdenv.mkDerivation {
          pname = "k0s";
          version = "1.32.4+k0s.0"; # change as needed

          src = pkgs.fetchurl {
            url = "https://github.com/k0sproject/k0s/releases/download/v1.32.4%2Bk0s.0/k0s-v1.32.4+k0s.0-amd64";
            sha256 = "sha256-fxXYT5Ddw6F+XuW6y1M7C4iZuPSip+eP627r+Zm1ly8="; # Update with actual hash
          };

          phases = [ "installPhase" ];
          installPhase = ''
            mkdir -p $out/bin
            install -m755 $src $out/bin/k0s
          '';
        };

      in {
        packages.default = k0s;
        
        apps.default = {
          type = "app";
          program = "${k0s}/bin/k0s";
        };

        devShells.default = pkgs.mkShell {
          packages = [ k0s pkgs.kubectl pkgs.k0sctl pkgs.lens ];
        };
      });
}
