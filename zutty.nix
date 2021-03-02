{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2021-02-28g${builtins.substring 0 9 src.rev}";
  src = pkgs.fetchFromGitHub rec {
    owner = "tomszilagyi";
    repo = "${pname}";
    rev = "1c0f99b31497d0f75ee7bbb46e67ae5c0f775fdd";
    sha256 = "1riw5k32ph217h0c5izj5lmq2mq0p623a6n6pvw1j8lxw79rj392";
  };
  nativeBuildInputs = with pkgs; [ pkgconfig python wafHook ];
  buildInputs = with pkgs; [ xorg.libXaw freetype libglvnd ];
}
