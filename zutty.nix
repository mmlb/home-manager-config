{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "zutty";
  version = "unstable-2021-03-20g${builtins.substring 0 9 src.rev}";
  src = pkgs.fetchFromGitHub rec {
    owner = "tomszilagyi";
    repo = "${pname}";
    rev = "308a237ce3d241b4e46b5cc62b0b5508b1d6ea7e";
    sha256 = "1m3fqzni1azmnhiv6yqwynq70mgql2rr0qww1cjv872j77xynq0c";
  };
  nativeBuildInputs = with pkgs; [ pkgconfig python wafHook ];
  buildInputs = with pkgs; [ xorg.libXaw freetype libglvnd ];
}
