{
  description = "DIBAR — a Dynamic Island-style shell for Hyprland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = pkgsFor system;
          dibar = pkgs.callPackage ./nix/package.nix { };
        in
        {
          default = dibar;
          inherit dibar;
        });

      apps = forAllSystems (system: {
        default = {
          type = "app";
          program = "${self.packages.${system}.dibar}/bin/dibar";
        };

        dibar = {
          type = "app";
          program = "${self.packages.${system}.dibar}/bin/dibar";
        };
      });

      devShells = forAllSystems (system:
        let
          pkgs = pkgsFor system;
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              quickshell
              brightnessctl
              ddcutil
              cliphist
              wl-clipboard
            ];
          };
        });

      formatter = forAllSystems (system: (pkgsFor system).nixfmt);
    };
}
