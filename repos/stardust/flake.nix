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

      stardust =
        with pkgs;
        stdenv.mkDerivation {
          name = "stardust";
          version = "0.1";
          src = ./.;

          buildInputs = [ SDL2 ];
          nativeBuildInputs = [
            zig
            pkg-config
          ];

          buildPhase = ''
            	  echo $SDL2_NS_PATH
                      HOME=$(mktemp -d)
                      zig build stardust -p $out
          '';
        };

      webDeps =
        with pkgs;
        stdenv.mkDerivation {
          name = "stardustWebDeps";
          version = "0.1";
          src = SDL2.src;

          buildInputs = [ SDL2 ];
          nativeBuildInputs = [
            zig
            emscripten
            cmake
          ];

          configurePhase = ''
                      HOME=$(mktemp -d)
            	  emcmake cmake -B $out 
            	  mkdir -p $out/include/emscripten
            	'';
          buildPhase = ''
            emmake make -C $out
            cp -r ${emscripten}/share/emscripten/cache/sysroot/include $out/include/emscripten
          '';
        };

      stardustWeb =
        with pkgs;
        stdenv.mkDerivation {
          name = "stardustWeb";
          version = "0.1";
          src = ./.;

          buildInputs = [
            SDL2
            webDeps
          ];
          nativeBuildInputs = [
            zig
            emscripten
          ];

          buildPhase = ''
            	  HOME=$(mktemp -d)
            	  export WEB_DEPS=${webDeps}
                      zig build stardustWeb -p $out
          '';
        };

    in
    {
      packages.${system} = {
        default = stardust;
        inherit stardustWeb webDeps;
      };

      devShells.${system}.default = pkgs.mkShell {
        inputsFrom = [ stardust ];
      };
    };
}
