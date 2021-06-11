{ pkgs, ... }:
(import (pkgs.fetchFromGitHub {
  owner = "nix-community";
  repo = "lorri";
  #branch@date: master@2021-05-26
  rev = "dd45c1f0ebea90102a0fe9b5fcc701302e71f1f6";
  sha256 = "0hqml8ml76k1s8v6a0rzcf9sns87b2xnqplxm45cgp2rjs4qi2iz";
}))
