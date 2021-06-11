{ pkgs, ... }:
(import (pkgs.fetchFromGitHub {
  owner = "target";
  repo = "lorri";
  #branch@date: master@2021-06-11
  rev = "f3ac576d660ceb587d7692a993088cf78e881fc0";
  sha256 = "0h2xczfhg8ymr5k078vmvr9lijmviaab7bg18hv3i8hc9hdkdbnk";
}))
