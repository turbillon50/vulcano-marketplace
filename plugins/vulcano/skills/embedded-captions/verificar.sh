#!/usr/bin/env bash
# Verifica embedded-captions HOY: el test de preview (SRI de GSAP) en verde,
# gen-stroke-path.py tiende una palabra en path Hershey real, ffmpeg genera
# la base de prepare.sh — y el veredicto honesto sobre el checkout de
# hyperframes: sin packages/cli/dist/cli.js, matte.cjs y transcribe.cjs
# salen 3 y la tuberia (paso 2) no puede correr. Eso es ROTA hoy.
. /root/skills-vault/_lib/verif.sh
echo "verificando embedded-captions"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "test de preview-frames (SRI del GSAP interceptado)"
OUT=$(cd "$D/scripts" && node --test preview-frames.test.mjs 2>&1); RC=$?
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -qE '^# pass [1-9]'; then ok "SRI en verde"; else falla "node --test salio $RC"; fi

paso "gen-stroke-path.py tiende una palabra en path de pluma"
P=$(python3 "$D/scripts/gen-stroke-path.py" "$D/assets/strokefonts/HersheyScript1.svg" "VERIFICA" 600 300 40 2>/dev/null | head -1)
case "$P" in M*L*|M*) ok "path d de ${#P} chars";; *) falla "no emitio path d";; esac

paso "ffmpeg genera el video base de prepare.sh"
ffmpeg -hide_banner -loglevel error -f lavfi -i "testsrc=duration=1:size=320x240:rate=10" -pix_fmt yuv420p "$_t/src.mp4" >/dev/null 2>&1
[ -s "$_t/src.mp4" ] && ok "$(wc -c < "$_t/src.mp4") bytes" || falla "ffmpeg fallo"

paso "checkout built de hyperframes (matte.cjs/transcribe.cjs lo exigen)"
ROOT=""
for c in "${HYPERFRAMES_ROOT:-}" "$D/../.." "$D/../../.." "$HOME/Downloads/hyperframes"; do
  [ -n "$c" ] && [ -f "$c/packages/cli/dist/cli.js" ] && { ROOT="$c"; break; }
done
if [ -n "$ROOT" ]; then ok "$ROOT"; else falla "sin checkout built (HYPERFRAMES_ROOT) — clonar hyperframes, bun install && bun run build"; fi
rm -rf "$_t"
cierra
