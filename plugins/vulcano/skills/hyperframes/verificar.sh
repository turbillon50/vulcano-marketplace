#!/usr/bin/env bash
# Verifica el punto de entrada HyperFrames HOY: el CLI responde, las 10 rutas
# del routing existen con contenido, y frame-packets-core.mjs (el codigo que
# comparten los workflows) divide un storyboard y lee campos de verdad.
. /root/skills-vault/_lib/verif.sh
echo "verificando hyperframes"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 22 >/dev/null 2>&1
export HOME=/root
D=$(cd "$(dirname "$0")" && pwd)

paso "CLI hyperframes responde"
V=$(timeout 50 npx -y hyperframes --version 2>/dev/null | tail -1)
case "$V" in 0.*) ok "$V";; *) falla "npx hyperframes --version no dio version";; esac

paso "las 10 rutas del routing existen y tienen contenido"
falt=0; n=0
for r in slideshow embedded-captions talking-head-recut music-to-video motion-graphics \
         pr-to-video product-launch-video faceless-explainer general-video remotion-to-hyperframes; do
  n=$((n+1))
  [ -s "$D/references/routes/$r.md" ] || { falt=$((falt+1)); printf '  falta references/routes/%s.md\n' "$r" >&2; }
done
if [ "$falt" -eq 0 ]; then ok "$n rutas"; else falla "$falt rutas faltantes o vacias"; fi

paso "frame-packets-core.mjs parte un storyboard de verdad"
OUT=$(node --input-type=module -e "
import { pathToFileURL } from 'node:url';
const m = await import(pathToFileURL('$D/scripts/lib/frame-packets-core.mjs').href);
const sb = '---\nformat: 1920x1080\n---\n\n## Frame 1 — A\n\n- duration: 3s\n- src: compositions/a.html\n\n## Frame 2 — B\n\n- duration: 4s\n- src: compositions/b.html\n';
const f = m.splitFrames(sb);
if (f.length !== 2) process.exit(1);
if (m.field(f[0].block, 'duration') !== '3s') process.exit(1);
if (m.frameId(f[0]) !== 'a') process.exit(1);
console.log('OK 2 frames, duration leido, frameId=a');
" 2>&1)
case "$OUT" in OK*) ok "${OUT#OK }";; *) falla "el core no dividio el storyboard: $OUT";; esac

paso "contratos de referencia presentes (brief, review, produccion, worker)"
n=$(find "$D/references" -maxdepth 1 -name '*.md' -size +100c | wc -l)
[ "$n" -ge 14 ] && ok "$n documentos" || falla "solo $n documentos con contenido en references/"

debe_reprobar "una ruta que no existe no pasa el routing" \
  test -s "$D/references/routes/no-existe-zz.md"
cierra
