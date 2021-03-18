{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2021-03-13g${builtins.substring 0 9 src.rev}";
  src = pkgs.fetchFromGitHub rec {
    owner = "tomszilagyi";
    repo = "${pname}";
    rev = "eaa36ca6af174b06c9c1bd759cec00b435718756";
    sha256 = "04xn56z2ynmz7h1mjppyixwbw6rvgfyi8zlydrlgvpbg7c0vl9il";
  };
  nativeBuildInputs = with pkgs; [ pkgconfig python wafHook ];
  buildInputs = with pkgs; [ xorg.libXaw freetype libglvnd ];
}
