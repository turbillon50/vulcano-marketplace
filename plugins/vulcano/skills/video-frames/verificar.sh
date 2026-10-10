#!/usr/bin/env bash
# Verifica video-frames HOY: ffmpeg codifica un video de verdad, frame.sh
# extrae el frame (por indice y por timestamp) y la salida es un JPEG que
# ffprobe puede decodificar — no solo "el binario existe".
. /root/skills-vault/_lib/verif.sh
echo "verificando video-frames"
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "ffmpeg genera el video de prueba"
ffmpeg -hide_banner -loglevel error -f lavfi -i "testsrc=duration=1:size=320x240:rate=10" -pix_fmt yuv420p "$_t/v.mp4" >/dev/null 2>&1
if [ -s "$_t/v.mp4" ]; then ok "$(wc -c < "$_t/v.mp4") bytes"; else falla "ffmpeg no pudo generar el video"; fi

paso "frame.sh extrae el frame por indice"
OUT=$(bash "$D/scripts/frame.sh" "$_t/v.mp4" --index 0 --out "$_t/f0.jpg" 2>/dev/null)
if [ -s "$_t/f0.jpg" ]; then ok "$(wc -c < "$_t/f0.jpg") bytes"; else falla "frame.sh no produjo el frame: $OUT"; fi

paso "el frame extraido se decodifica como JPEG"
C=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of csv=p=0 "$_t/f0.jpg" 2>/dev/null)
case "$C" in mjpeg|jpeg|png) ok "codec $C";; *) falla "ffprobe dice '$C', no una imagen";; esac

paso "frame.sh respeta --time"
bash "$D/scripts/frame.sh" "$_t/v.mp4" --time 00:00:00 --out "$_t/ft.jpg" >/dev/null 2>&1
[ -s "$_t/ft.jpg" ] && ok "$(wc -c < "$_t/ft.jpg") bytes" || falla "extraccion por timestamp vacia"

debe_reprobar "frame.sh se niega ante un video inexistente" \
  bash "$D/scripts/frame.sh" "$_t/no-existe.mp4" --out "$_t/x.jpg"
rm -rf "$_t"
cierra
