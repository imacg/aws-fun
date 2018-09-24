{ pkgs ? import <nixpkgs> {}, ... }:
pkgs.stdenv.mkDerivation {
  name = "aws-fun";
  buildInputs = with pkgs; [ awscli terraform nix-deploy wrk ];
}
  
