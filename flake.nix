{
  description = "<ADD YOUR DESCRIPTION>";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    gomod2nix = {
      url = "github:tweag/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "utils";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-utils,
    gomod2nix,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [gomod2nix.overlays.default];
      };
    in {
      devShells = {
        default = pkgs.mkShell {
          #          inherit (self.checks.${system}.pre-commit-check) shellHook;
          buildInputs = with pkgs; [
            go
            go-tools
            golangci-lint
            goreleaser
            gomod2nix.packages.${system}.default
          ];
        };
      };

      packages = {
        default = pkgs.buildGoApplication {
          pname = "crafting-interpreters-in-go";
          version = "0.0.1";
          src = ./.;
          modules = ./gomod2nix.toml;
        };
      };
    });
}
