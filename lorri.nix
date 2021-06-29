{ pkgs, ... }:
(import (pkgs.fetchFromGitHub {
  owner = "nix-community";
  repo = "lorri";
  #branch@date: master@2021-06-21
  rev = "dfbf9b3d22474380ee5e096931dbf25b1c162d10";
  sha256 = "0n3n0wq6s13yznljrqqsjvjxjk6lg9j4bkxpxl2l517s6012hvxs";
}))
