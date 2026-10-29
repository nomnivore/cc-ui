# .envrc: use flake
{
  description = "DevShell flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    cc-types = {
      url = "gitlab:carsakiller/cc-tweaked-documentation";
      flake = false;
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      cc-types,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = pkgs.mkShell {
          packages = with pkgs; [
            # bun
            craftos-pc
            stylua
            lua5_3
            lua53Packages.busted
          ];
          shellHook = ''
            mkdir -p .lls
            ln -sfn ${cc-types}/library .lls/cc-tweaked
          '';
        };
      }
    );
}
