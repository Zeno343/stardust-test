{
  description = ''
    Stardust: a Zig graphics library
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      stardust = pkgs.stdenv.mkDerivation {
        name = "stardust";
        version = "0.1";
        src = ./.;

        buildInputs = with pkgs; [ SDL2 ];
        nativeBuildInputs = with pkgs; [
          zig
          pkg-config
        ];

        buildPhase = ''
          HOME=$(mktemp -d)
          zig build stardust -p $out
        '';
      };
    in
    {
      packages.${system}.default = stardust;
      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ stardust ];
      };
    };
}
