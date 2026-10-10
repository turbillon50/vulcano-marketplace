#!/usr/bin/env bash
# Verifica faceless-explainer HOY: los cinco juegos de tests del workflow
# (captions, assemble-index, transitions, audio —incluida su identidad
# byte-a-byte con pr-to-video— y frame-packets) en verde, el registro de
# transiciones parsea, y ffmpeg produce el audio que audio.mjs consume.
. /root/skills-vault/_lib/verif.sh
echo "verificando faceless-explainer"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "tests del workflow (captions, assemble, transitions, audio, frame-packets)"
OUT=$(cd "$D/scripts" && node --test captions.test.mjs assemble-index.test.mjs transitions.test.mjs audio.test.mjs frame-packets.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then
  ok "$P tests"
elif printf '%s' "$OUT" | grep -q 'packages/cli/src/media-use/lib/media-fetch.mjs'; then
  T=$(printf '%s' "$OUT" | grep -E '^# tests ' | tail -1 | grep -oE '[0-9]+')
  falla "$P de $T tests — assemble-index muere al importar: el shim media-use/lib/media-fetch.mjs apunta al monorepo (/root/packages/cli) y en el servidor no existe ese checkout"
else
  falla "node --test salio $RC: $(printf '%s' "$OUT" | grep -E '^# fail [1-9]' | head -1)"
fi

paso "el registro de transiciones vendido parsea y trae entradas"
N=$(node -e "
const t = JSON.parse(require('fs').readFileSync('$D/scripts/lib/transitions.json','utf8'));
const n = Array.isArray(t) ? t.length : Object.keys(t).length;
if (n < 3) process.exit(1);
console.log(n);
" 2>&1)
case "$N" in ''|*Error*) falla "transitions.json no parsea: $N";; *) ok "$N transiciones";; esac

paso "ffmpeg genera el audio que audio.mjs consume"
ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=330:duration=0.5" -y "$_t/vo.wav" >/dev/null 2>&1
[ -s "$_t/vo.wav" ] && ok "$(wc -c < "$_t/vo.wav") bytes" || falla "ffmpeg fallo"
rm -rf "$_t"
cierra
