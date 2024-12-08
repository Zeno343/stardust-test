{
  description = ''
    Stardust: a Zig graphics library
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { nixpkgs, ... }:
    with nixpkgs.legacyPackages."x86_64-linux";
    {
      devShells."x86_64-linux".default = mkShell {
        buildInputs = [ SDL2 ];
        nativeBuildInputs = [
          zig
          pkg-config
          emscripten
        ];
      };
    };
}
