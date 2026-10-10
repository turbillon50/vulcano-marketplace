#!/usr/bin/env bash
# Verifica talking-head-recut HOY: el contrato canonico de media (test que
# exige el <video> muted + <audio> espejo con pista distinta) en verde, los
# assets de marca (GSAP vendido + fuentes woff2) con bytes reales, y el par
# ffmpeg/ffprobe leyendo un video con audio — la materia prima del recut.
. /root/skills-vault/_lib/verif.sh
echo "verificando talking-head-recut"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "test del contrato de media (audio espejo del video, pista propia)"
OUT=$(cd "$D" && node --test media-contract.test.mjs 2>&1); RC=$?
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -qE '^# pass [1-9]'; then ok "contrato en verde"; else falla "el contrato canonico falla"; fi

paso "assets de marca con bytes reales (GSAP + fuentes)"
G=$(wc -c < "$D/assets/vendor/gsap.min.js" 2>/dev/null)
F=$(find "$D/assets/fonts" -name '*.woff2' -size +1k | wc -l)
if [ "${G:-0}" -ge 50000 ] && [ "$F" -ge 6 ]; then ok "gsap ${G}b + $F fuentes woff2"; else falla "gsap=${G}b, fuentes=$F (se esperaba gsap >=50k y >=6 fuentes)"; fi

paso "ffmpeg genera y ffprobe lee video con audio (la materia prima)"
ffmpeg -hide_banner -loglevel error -f lavfi -i "testsrc=duration=1:size=320x240:rate=10" \
  -f lavfi -i "sine=frequency=440:duration=1" -c:v libx264 -pix_fmt yuv420p -c:a aac -shortest -y "$_t/clip.mp4" >/dev/null 2>&1
S=$(ffprobe -v error -show_entries stream=codec_type -of csv=p=0 "$_t/clip.mp4" 2>/dev/null | tr '\n' ' ')
case "$S" in *video*audio*|*audio*video*) ok "streams:$S";; *) falla "ffprobe no ve video+audio ('$S')";; esac

debe_reprobar "ffprobe se niega ante un mp4 vacio" ffprobe -v error -i /dev/null -show_entries format=duration
rm -rf "$_t"
cierra
