#!/usr/bin/env bash
# Verifica product-launch-video HOY: los nueve juegos de tests del workflow
# en verde (incluidos los guardarrailes de capture y el contrato de media),
# y el CLI de hyperframes exponiendo `capture` — el paso 1 del workflow.
# La llave GEMINI/GOOGLE es opcional (media-use degrada a busqueda).
. /root/skills-vault/_lib/verif.sh
echo "verificando product-launch-video"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 22 >/dev/null 2>&1
export HOME=/root
D=$(cd "$(dirname "$0")" && pwd)

paso "tests del workflow (captions, assemble, transitions, audio, packets, staging, contratos)"
OUT=$(cd "$D/scripts" && node --test *.test.mjs lib/*.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
T=$(printf '%s' "$OUT" | grep -E '^# tests ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then
  ok "$P tests"
elif printf '%s' "$OUT" | grep -q 'packages/cli/src/media-use/lib/media-fetch.mjs'; then
  falla "$P de $T tests — assemble-index muere al importar: el shim media-use/lib/media-fetch.mjs apunta al monorepo (/root/packages/cli) y en el servidor no existe ese checkout"
else
  falla "node --test salio $RC: $(printf '%s' "$OUT" | grep -E '^# fail [1-9]' | head -1)"
fi

paso "el CLI trae capture (paso 1: captura del sitio, con BLOCKED.md como gate)"
HF=$(timeout 50 npx -y hyperframes --help 2>&1)
if printf '%s' "$HF" | grep -qE '^  +capture'; then ok "capture presente"; else falla "hyperframes sin capture — el workflow no puede arrancar"; fi

paso "llave para generacion de imagenes (opcional, hay fallback a busqueda)"
if [ -n "$(env_get GEMINI_API_KEY)" ] || [ -n "$(env_get GOOGLE_API_KEY)" ]; then
  ok "GEMINI/GOOGLE presente"
else
  ok "ausente — media-use degrada a busqueda, la skill sigue servible"
fi

debe_reprobar "el guardarrail de capture vive: SKILL.md exige BLOCKED.md como hard stop" \
  test -z "$(grep -l 'capture/BLOCKED.md' "$D/SKILL.md")"
cierra
