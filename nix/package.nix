{
  lib,
  stdenvNoCC,
  makeWrapper,
  quickshell,
}:

stdenvNoCC.mkDerivation {
  pname = "dibar";
  version = "0.1.0";

  src = ../.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/dibar
    mkdir -p $out/bin

    cp -r \
      Assets \
      Components \
      Config \
      Controllers \
      Controls \
      Services \
      Views \
      Island.qml \
      IslandSurface.qml \
      shell.qml \
      $out/share/dibar/

    makeWrapper ${quickshell}/bin/qs $out/bin/dibar \
      --add-flags "-p $out/share/dibar"

    runHook postInstall
  '';

  meta = {
    description = "Dynamic Island-style shell for Hyprland";
    homepage = "https://github.com/SergioM26/dynamic-island-bar";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "dibar";
  };
}
