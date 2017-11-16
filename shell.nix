{ nixpkgs ? import <nixpkgs> {}, compiler ? "default" }:

let

  inherit (nixpkgs) pkgs;

  f = { mkDerivation, attoparsec, base, nix-derivation, stdenv
      , text, tree-diff
      }:
      mkDerivation {
        pname = "diff-drv";
        version = "0.1.0.0";
        src = ./.;
        isLibrary = false;
        isExecutable = true;
        executableHaskellDepends = [
          attoparsec base nix-derivation text tree-diff
        ];
        license = stdenv.lib.licenses.mit;
      };

  haskellPackages = if compiler == "default"
                       then pkgs.haskellPackages
                       else pkgs.haskell.packages.${compiler};

  drv = (haskellPackages.override {
    overrides = self: super: {
      tree-diff = pkgs.haskell.lib.doJailbreak super.tree-diff;
      QuickCheck = super.QuickCheck_2_10_1;
      blaze-markup = pkgs.haskell.lib.dontCheck super.blaze-markup;
      blaze-html = pkgs.haskell.lib.dontCheck super.blaze-html;
      distributive = pkgs.haskell.lib.dontCheck super.distributive;
      parsers = pkgs.haskell.lib.dontCheck super.parsers;
      attoparsec = pkgs.haskell.lib.dontCheck super.attoparsec;
      nix-derivation = pkgs.haskell.lib.dontCheck super.nix-derivation;
      aeson = pkgs.haskell.lib.dontCheck super.aeson_1_2_3_0;
    };
  }).callPackage f {};

in

  if pkgs.lib.inNixShell then drv.env else drv
