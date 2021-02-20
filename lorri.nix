{ pkgs, ... }:
(import (pkgs.fetchFromGitHub {
  owner = "target";
  repo = "lorri";
  #branch@date: master@2020-11-13
  rev = "66536ab4a503e2c30f948849e9b655ad5c0f0708";
  sha256 = "08jb2vgbm4s87wnk7q82yc55dd2b8fyn7v8vsarjamwhna2fh7py";
}))
