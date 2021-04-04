{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2021-04-03g${builtins.substring 0 9 src.rev}";
  src = pkgs.fetchFromGitHub rec {
    owner = "tomszilagyi";
    repo = "${pname}";
    rev = "c76b27cd24cab117f7b9051de83c7976aa66b836";
    sha256 = "15x7ywzyvz2lbd35xdaryxaymczwzq8lv66q6icl0dj7q0zjbm4w";
  };
  nativeBuildInputs = with pkgs; [ pkgconfig python wafHook ];
  buildInputs = with pkgs; [ xorg.libXaw freetype libglvnd ];
}
