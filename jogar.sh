#!/bin/bash
# Abre o jogo (Godot 4.7.2 já baixado em ferramentas/godot). Controles: setas ou A/D, Espaço, Shift.
cd "$(dirname "$0")/jogo" && exec ../ferramentas/godot/Godot_v4.7.2-stable_linux.x86_64 --path .
