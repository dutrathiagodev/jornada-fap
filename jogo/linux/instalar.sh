#!/usr/bin/env bash
# Instala o Jornada FAP para o usuário atual (sem sudo):
# copia o jogo, cria a entrada no menu de aplicativos e o atalho na área de trabalho.
set -e
AQUI="$(cd "$(dirname "$0")" && pwd)"
DESTINO="$HOME/.local/share/JornadaFAP"

mkdir -p "$DESTINO" "$HOME/.local/share/applications"
cp "$AQUI/JornadaFAP.x86_64" "$AQUI/icone.png" "$DESTINO/"
chmod +x "$DESTINO/JornadaFAP.x86_64"

ATALHO="[Desktop Entry]
Type=Application
Name=Jornada FAP
Comment=Corra, pule e aprenda por 5 cidades
Exec=\"$DESTINO/JornadaFAP.x86_64\"
Path=$DESTINO
Icon=$DESTINO/icone.png
Terminal=false
Categories=Game;Education;
StartupNotify=true"

echo "$ATALHO" > "$HOME/.local/share/applications/jornada-fap.desktop"

AREA="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
if [ -d "$AREA" ]; then
    echo "$ATALHO" > "$AREA/Jornada FAP.desktop"
    chmod +x "$AREA/Jornada FAP.desktop"
    # GNOME: marca o atalho como confiável para abrir com dois cliques
    gio set "$AREA/Jornada FAP.desktop" metadata::trusted true 2>/dev/null || true
fi

command -v update-desktop-database >/dev/null 2>&1 && update-desktop-database "$HOME/.local/share/applications" || true
echo "Jornada FAP instalado! Procure o atalho na área de trabalho ou no menu de aplicativos."
echo "Para remover: rm -rf ~/.local/share/JornadaFAP ~/.local/share/applications/jornada-fap.desktop \"$AREA/Jornada FAP.desktop\""
