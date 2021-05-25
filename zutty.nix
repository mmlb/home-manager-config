{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2021-05-22g${builtins.substring 0 9 src.rev}";
  src = pkgs.fetchFromGitHub rec {
    owner = "tomszilagyi";
    repo = "${pname}";
    rev = "b8849be6f1374cda071976359e2b19f97deb5753";
    sha256 = "1c6na1whnxpfz7ykjcxgy8wzm6jv0my2fx1nh2mi1q6fns8j6cwk";
  };
  nativeBuildInputs = with pkgs; [ pkgconfig python wafHook ];
  buildInputs = with pkgs; [ xorg.libXaw freetype libglvnd ];
}
