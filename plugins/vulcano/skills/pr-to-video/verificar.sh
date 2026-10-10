#!/usr/bin/env bash
# Verifica pr-to-video HOY: los cuatro juegos de tests del workflow en verde,
# el preflight propio (que sondea `npx hyperframes --help` buscando los
# subcomandos que la skill exige), y una sesion REAL de gh leyendo la cuota
# de la API con GITHUB_TOKEN de /root/.env — sin gh no hay PR de entrada.
. /root/skills-vault/_lib/verif.sh
echo "verificando pr-to-video"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 22 >/dev/null 2>&1
export HOME=/root
D=$(cd "$(dirname "$0")" && pwd)

paso "tests del workflow (captions, assemble, frame-contract, guardarrailes)"
OUT=$(cd "$D/scripts" && node --test captions.test.mjs assemble-index.test.mjs frame-contract.test.mjs workflow-guardrails.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
T=$(printf '%s' "$OUT" | grep -E '^# tests ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then
  ok "$P tests"
elif printf '%s' "$OUT" | grep -q 'packages/cli/src/media-use/lib/media-fetch.mjs'; then
  falla "$P de $T tests — assemble-index muere al importar: el shim media-use/lib/media-fetch.mjs apunta al monorepo (/root/packages/cli) y en el servidor no existe ese checkout"
else
  falla "node --test salio $RC: $(printf '%s' "$OUT" | grep -E '^# fail [1-9]' | head -1)"
fi

paso "preflight propio: el CLI trae los subcomandos que el workflow exige"
if OUT2=$(node "$D/scripts/preflight.mjs" 2>&1) && printf '%s' "$OUT2" | grep -q 'preflight: required CLI capabilities'; then
  ok "${OUT2#*preflight: }"
else
  falla "$OUT2"
fi

paso "sesion gh real (GITHUB_TOKEN de /root/.env contra la API)"
GT=$(env_get GITHUB_TOKEN)
[ -z "$GT" ] && GT=$(env_get GH_TOKEN)
if [ -z "$GT" ]; then bloqueada "ni GITHUB_TOKEN ni GH_TOKEN en /root/.env — fetch-pr.mjs lee el PR via gh"; fi
Q=$(GH_TOKEN="$GT" timeout 25 gh api rate_limit --jq '.resources.core.remaining' 2>&1)
case "$Q" in ''|*Bad*|*Invalid*|*message*) bloqueada "el token de GitHub no sirve (gh api dijo: $(printf '%s' "$Q" | head -1)) — rotarlo";; *) ok "cuota core restante: $Q";; esac

debe_reprobar "un token podrido no pasa la API de GitHub" \
  env GH_TOKEN=podrido-zz99 gh api rate_limit
cierra
