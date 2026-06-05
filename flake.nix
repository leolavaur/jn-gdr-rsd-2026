{
  description = "Reproducible PDF build for Beamer slides";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
  };

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f (import nixpkgs { inherit system; }));
    in
    {
      packages = forAllSystems (
        pkgs:
        let
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              scheme-small
              latexmk
              beamer
              pgf
              moloch
              xetex
              ;
          };
        in
        rec {
          pdf = pkgs.stdenvNoCC.mkDerivation {
            pname = "slides";
            version = "0.1.0";
            src = self;

            nativeBuildInputs = [ tex ];

            buildPhase = ''
              runHook preBuild
              mkdir -p build
              latexmk -pdf -interaction=nonstopmode -halt-on-error -output-directory=build main.tex
              runHook postBuild
            '';

            installPhase = ''
              runHook preInstall
              mkdir -p $out
              cp build/main.pdf $out/slides.pdf
              runHook postInstall
            '';
          };

          default = pdf;
        }
      );
    };
}
