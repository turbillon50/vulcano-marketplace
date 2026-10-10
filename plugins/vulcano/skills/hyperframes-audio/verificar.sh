#!/usr/bin/env bash
# Verifica hyperframes-audio HOY: los tests de carve (grupos voz/cama,
# deteccion de tracks, guard del CLI) en verde, y ffmpeg aplica una cadena
# real del dominio de la skill (fade + volumen) sobre audio generado.
. /root/skills-vault/_lib/verif.sh
echo "verificando hyperframes-audio"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "tests de carve.mjs (grupos, fuentes, parseo)"
OUT=$(cd "$D/scripts" && node --test carve.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then ok "$P tests"; else falla "node --test salio $RC"; fi

paso "ffmpeg aplica la cadena del dominio (sine -> afade + volume -> wav)"
ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:duration=1" \
  -af "afade=t=in:d=0.2,afade=t=out:st=0.8:d=0.2,volume=0.5" -y "$_t/mez.wav" >/dev/null 2>&1
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$_t/mez.wav" 2>/dev/null)
case "$DUR" in 1*|0.9*|1.0*) ok "duración ${DUR}s";; *) falla "ffprobe dice '$DUR'";; esac

paso "ffprobe ve el audio con samples reales (no silencio digital)"
V=$(ffmpeg -hide_banner -i "$_t/mez.wav" -af volumedetect -f null - 2>&1 | grep -oE 'mean_volume: [-0-9.]+ dB' | head -1)
case "$V" in mean_volume:*-*) ok "$V";; *) falla "volumedetect no midio nada";; esac

debe_reprobar "carve.mjs sin --comp se niega (usage, exit 1)" \
  node "$D/scripts/carve.mjs"
rm -rf "$_t"
cierra
