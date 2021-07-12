{ fetchFromGitHub
, fetchpatch
, glib
, gobject-introspection
, meson
, ninja
, pkg-config
, lib, stdenv
, wrapGAppsHook
, libxml2
, gtk3
, libnotify
, cinnamon-desktop
, xapps
, libexif
, exempi
, intltool
, shared-mime-info
, cinnamon-translations
, libgsf
}:

stdenv.mkDerivation rec {
  pname = "nemo";
  version = "5.0.3";

  # TODO: add plugins support (see https://github.com/NixOS/nixpkgs/issues/78327)

  src = fetchFromGitHub {
    owner = "linuxmint";
    repo = pname;
    rev = version;
    sha256 = "sha256-Ah1Rp/o4LPdYm+wj2W5ljjMkCI3PgoAHrlM8yEQP77o=";
  };

  outputs = [ "out" "dev" ];

  buildInputs = [
    glib
    gtk3
    libnotify
    cinnamon-desktop
    libxml2
    xapps
    libexif
    exempi
    gobject-introspection
    libgsf
  ];

  nativeBuildInputs = [
    meson
    pkg-config
    ninja
    wrapGAppsHook
    intltool
    shared-mime-info
  ];

  mesonFlags = [
    # TODO: https://github.com/NixOS/nixpkgs/issues/36468
    "-Dc_args=-I${glib.dev}/include/gio-unix-2.0"
    # use locales from cinnamon-translations
    "--localedir=${cinnamon-translations}/share/locale"
  ];

  meta = with lib; {
    homepage = "https://github.com/linuxmint/nemo";
    description = "File browser for Cinnamon";
    license = [ licenses.gpl2 licenses.lgpl2 ];
    platforms = platforms.linux;
    maintainers = teams.cinnamon.members;
  };
}
