{ pkgs, ... }:
(import (pkgs.fetchFromGitHub {
  owner = "target";
  repo = "lorri";
  #branch@date: master@2020-02-06
  rev = "b2f1fe218ab95ce7c89c4b35644d01c4c1f1b21d";
  sha256 = "0yliffg3kpmdi2nk1xjhizsnz03djnjj8pw5k3gryz7hh2cyvyx7";
}))
