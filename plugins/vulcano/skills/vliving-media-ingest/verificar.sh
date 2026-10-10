#!/usr/bin/env bash
# Verifica vliving-media-ingest HOY: gdown puede bajar la carpeta Drive,
# hay sesion de Vercel (el env efimero de vliving-2026 sale de ahi), el repo
# esta clonado y ligado, y las dependencias node del ingest (sharp/pg)
# resuelven. Sin sharp el ingest.mjs muere en la linea 10 — eso es ROTA hoy.
. /root/skills-vault/_lib/verif.sh
echo "verificando vliving-media-ingest"
export HOME=/root
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
REPO=/root/repos/vliving-2026

paso "gdown para bajar la carpeta de Drive"
GD=/root/tools/gdown-venv/bin/gdown
if [ -x "$GD" ] && "$GD" --version 2>/dev/null | grep -q '^gdown '; then
  ok "$("$GD" --version 2>/dev/null | head -1 | cut -d' ' -f1-2) (venv /root/tools)"
elif python3 -m gdown --version >/dev/null 2>&1; then
  ok "python3 -m gdown"
else
  falla "ni venv /root/tools/gdown-venv ni gdown en python3"
fi

paso "sesion de Vercel (de ahi sale el env efimero)"
U=$(timeout 25 vercel whoami 2>/dev/null | tail -1)
case "$U" in https*|"") bloqueada "sin sesion de Vercel (vercel login) — el paso 7 de la skill necesita vercel env pull";; *) ok "$U";; esac

paso "repo vliving-2026 clonado y ligado a su proyecto"
if [ -s "$REPO/lib/objeto.js" ] && [ -s "$REPO/.vercel/project.json" ]; then
  ok "$(sed -n 's/.*"projectName":"\([^"]*\)".*/\1/p' "$REPO/.vercel/project.json")"
else
  falla "falta $REPO/lib/objeto.js o el link .vercel — clonar de GitHub y vercel link"
fi

paso "dependencias node del ingest (sharp + pg via package.json del repo)"
DEPS=$(node -e "
const {createRequire}=require('module');
const r=createRequire('$REPO/package.json');
let out=[];
for (const m of ['sharp','pg']) { try { r(m); out.push(m+':ok'); } catch { out.push(m+':FALTA'); } }
console.log(out.join(' '));
" 2>&1)
case "$DEPS" in *sharp:ok*) ok "$DEPS";; *) falla "$DEPS — correr npm install en $REPO (el barrido limpia node_modules)";; esac

debe_reprobar "ingest.mjs sin argumentos se niega (args_required)" \
  node "$D/scripts/ingest.mjs"
cierra
