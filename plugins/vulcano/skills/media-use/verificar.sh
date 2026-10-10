#!/usr/bin/env bash
# Verifica media-use HOY: los tests unitarios (compatibilidad, transcript-cut,
# dither) en verde, ffmpeg/ffprobe (lo unico estrictamente requerido)
# procesando de verdad, y el doctor propio de la skill. Veredicto honesto:
# el setup exige heygen >= v0.3.0 UNIFORMEMENTE para la ruta gratis
# (bgm/sfx/imagen/voz/avatar) — sin sesion de heygen la skill queda
# BLOQUEADA aunque el lado local (grade/lut/operaciones) siga vivo.
. /root/skills-vault/_lib/verif.sh
echo "verificando media-use"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 22 >/dev/null 2>&1
export HOME=/root
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "tests unitarios (compatibility, transcript-cut, dither)"
OUT=$(cd "$D/scripts" && node --test compatibility.test.mjs transcript-cut.test.mjs dither.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then ok "$P tests"; else falla "node --test salio $RC: $(printf '%s' "$OUT" | grep -E '^# fail [1-9]' | head -1)"; fi

paso "ffmpeg/ffprobe procesan de verdad (operaciones y grades locales)"
ffmpeg -hide_banner -loglevel error -f lavfi -i "testsrc=duration=0.5:size=320x240:rate=10" -pix_fmt yuv420p "$_t/c.mp4" >/dev/null 2>&1
DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$_t/c.mp4" 2>/dev/null)
case "$DUR" in 0.*|1*) ok "clip de ${DUR}s decodificado";; *) falla "ffprobe no leyo el clip ('$DUR')";; esac
rm -rf "$_t"

paso "doctor propio de la skill (npx hyperframes media-use resolve --doctor)"
DOC=$(timeout 50 npx -y hyperframes media-use resolve --doctor 2>&1)
if [ -z "$DOC" ]; then
  falla "el doctor no dio salida (npx hyperframes fallo)"
elif printf '%s' "$DOC" | grep -qE 'heygen (not found|version unavailable|auth status unavailable)'; then
  NOK=$(printf '%s' "$DOC" | grep -c '✗')
  bloqueada "heygen sin instalar/sesion ($NOK chequeos en rojo) — media-use requires heygen >= v0.3.0 para la ruta gratis (bgm/sfx/imagen/voz/avatar); instalarlo y heygen auth login --oauth"
else
  NOK=$(printf '%s' "$DOC" | grep -c '✗')
  [ "$NOK" -eq 0 ] && ok "$(printf '%s' "$DOC" | grep -c '✓') chequeos en verde" || falla "$NOK chequeos del doctor en rojo"
fi
cierra
