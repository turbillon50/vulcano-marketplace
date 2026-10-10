#!/usr/bin/env bash
# Verifica general-video HOY: el armador de frame-packets pasa sus tests
# (que montan proyectos de_fixture y ejercitan el wrapper + el core compartido
# en ../hyperframes), y el wrapper compila.
. /root/skills-vault/_lib/verif.sh
echo "verificando general-video"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)

paso "tests del armador de frame-packets"
OUT=$(cd "$D/scripts" && node --test frame-packets.test.mjs 2>&1); RC=$?
P=$(printf '%s' "$OUT" | grep -E '^# pass ' | tail -1 | grep -oE '[0-9]+')
if [ "$RC" -eq 0 ] && [ -n "$P" ] && [ "$P" -gt 0 ]; then ok "$P tests"; else falla "node --test salio $RC: $(printf '%s' "$OUT" | grep -E '^# fail |^# pass ' | tr '\n' ' ')"; fi

paso "el wrapper resuelve sus rutas hermanas (core, animacion, worker role)"
falta=""
for f in ../hyperframes/scripts/lib/frame-packets-core.mjs \
         ../hyperframes-animation \
         ../hyperframes/references/frame-worker-core.md; do
  [ -e "$D/$f" ] || falta="$falta $f"
done
[ -z "$falta" ] && ok "core + animation + frame-worker-core al lado" || falla "faltan:$falta (la skill se copio sola, sin sus hermanas)"

paso "frame-packets.mjs compila"
if node --check "$D/scripts/frame-packets.mjs" 2>&1; then ok "sintaxis valida"; else falla "no compila"; fi

debe_reprobar "un frame sin src revienta el armador (missing src)" \
  node --input-type=module -e "
import { pathToFileURL } from 'node:url';
const m = await import(pathToFileURL('$D/../hyperframes/scripts/lib/frame-packets-core.mjs').href);
const f = m.splitFrames('## Frame 1\n\n- duration: 3s\n')[0];
process.exit(m.frameId(f) ? 0 : 3);
"
cierra
