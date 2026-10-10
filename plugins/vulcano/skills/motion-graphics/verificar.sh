#!/usr/bin/env bash
# Verifica motion-graphics HOY: locate.mjs (grounding sin API ni llave —
# nodo + ffmpeg) pinta la grilla RSVP y recorta la region fina sobre una
# imagen real; bake-basemap.mjs compila; el catalogo y las fases traen
# contenido. La llave GEMINI es opcional por diseño (hay fallback).
. /root/skills-vault/_lib/verif.sh
echo "verificando motion-graphics"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "catalogo, fases y grounding con contenido"
if [ -s "$D/catalog-map.md" ] && [ -s "$D/grounding/PROTOCOL.md" ] \
   && [ "$(find "$D/categories" -mindepth 1 -maxdepth 1 -type d | wc -l)" -ge 10 ] \
   && [ -n "$(find "$D/phases" -name '*.md' -size +100c | head -1)" ]; then
  ok "$(find "$D/categories" -mindepth 1 -maxdepth 1 -type d | wc -l) categorias"
else
  falla "catalogo/fases/grounding incompletos"
fi

paso "locate.mjs pinta la grilla RSVP (overlay) sobre una imagen real"
ffmpeg -hide_banner -loglevel error -f lavfi -i "testsrc=duration=0.1:size=640x360:rate=1" -frames:v 1 "$_t/img.png" >/dev/null 2>&1
if node "$D/grounding/locate.mjs" overlay "$_t/img.png" --out "$_t" >/dev/null 2>&1 \
   && [ -s "$_t/gv.png" ] && [ -s "$_t/gh.png" ]; then
  ok "gv+gh $(wc -c < "$_t/gv.png")/$(wc -c < "$_t/gh.png") bytes"
else
  falla "overlay no produjo las tiras gv.png/gh.png"
fi

paso "locate.mjs recorta la region fina (region 4,5 x 4,5)"
if node "$D/grounding/locate.mjs" region "$_t/img.png" --vids 4,5 --hids 4,5 --out "$_t" >/dev/null 2>&1 \
   && [ -s "$_t/gc.png" ]; then
  ok "gc.png $(wc -c < "$_t/gc.png") bytes"
else
  falla "region no produjo gc.png"
fi

paso "bake-basemap.mjs compila (corre completo solo con Chrome+red de tiles)"
if node --check "$D/categories/maps/bake-basemap.mjs" 2>&1; then ok "sintaxis valida"; else falla "no compila"; fi

debe_reprobar "locate mark sin --box se niega" \
  node "$D/grounding/locate.mjs" mark "$_t/img.png" --out "$_t/check.png"
rm -rf "$_t"
cierra
