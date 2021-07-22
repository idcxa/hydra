let
  rust-overlay = import (builtins.fetchTarball https://github.com/oxalica/rust-overlay/archive/master.tar.gz);
  nixpkgs = import <nixpkgs> {};
in
with nixpkgs;
nixpkgs.mkShell {
  buildInputs = [
    sumneko-lua-language-server
    love_11
    ];
  }
