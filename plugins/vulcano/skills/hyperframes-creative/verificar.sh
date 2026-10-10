#!/usr/bin/env bash
# Verifica hyperframes-creative HOY. OJO: package-loader.test.mjs vendido
# asume el monorepo hyperframes (resuelve el pin de version del package.json
# raiz) y desde el vault ese subtest no aplica. Este arnes prueba el
# COMPORTAMIENTO real: el ruteo Windows de npm via node + npm-cli.js, el
# fallback a @latest aislado del layout, extract-audio-data.py sacando
# RMS/bandas de audio real, y contrast-report exigiendo argumentos.
. /root/skills-vault/_lib/verif.sh
echo "verificando hyperframes-creative"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "package-loader rutea npm de Windows via node + npm-cli.js"
OUT=$(node --input-type=module -e "
import { pathToFileURL } from 'node:url';
const m = await import(pathToFileURL('$D/scripts/package-loader.mjs').href);
const npmCli = 'C:\\\\Program Files\\\\nodejs\\\\node_modules\\\\npm\\\\bin\\\\npm-cli.js';
const node = 'C:\\\\Program Files\\\\nodejs\\\\node.exe';
const r = m.resolveNpmSpawnCommand(['install','@hyperframes/producer@0.7.55','value & calc'],'win32',{npm_execpath:npmCli,npm_node_execpath:node},node,(p)=>p===npmCli);
if (r.cmd !== node || r.args[0] !== npmCli || r.opts.shell !== undefined) process.exit(1);
if (JSON.stringify(r.args.slice(1)) !== JSON.stringify(['install','@hyperframes/producer@0.7.55','value & calc'])) process.exit(2);
console.log('OK ruteo windows correcto, sin shell');
" 2>&1)
case "$OUT" in OK*) ok "${OUT#OK }";; *) falla "resolveNpmSpawnCommand: $OUT";; esac

paso "hyperframesPackageSpec cae a @latest aislado (layout sin repo, sin throw)"
mkdir -p "$_t/iso" && cp "$D/scripts/package-loader.mjs" "$_t/iso/"
printf '%s' 'import { hyperframesPackageSpec } from "./package-loader.mjs";process.stdout.write(hyperframesPackageSpec("@hyperframes/producer"));' > "$_t/iso/probe.mjs"
SPEC=$(cd "$_t/iso" && node probe.mjs 2>&1 | tail -1)
case "$SPEC" in @hyperframes/producer@latest) ok "fallback @latest";; @hyperframes/producer@*) ok "pinned $SPEC";; *) falla "spec raro: '$SPEC'";; esac

paso "extract-audio-data.py saca RMS/bandas de audio real"
ffmpeg -hide_banner -loglevel error -f lavfi -i "sine=frequency=440:duration=1" -y "$_t/a.wav" >/dev/null 2>&1
if python3 "$D/scripts/extract-audio-data.py" "$_t/a.wav" --fps 10 -o "$_t/ad.json" >/dev/null 2>&1 \
   && python3 -c "
import json
d=json.load(open('$_t/ad.json'))
frames=d if isinstance(d,list) else d.get('frames') or d.get('data') or []
assert len(frames)>=5, 'solo %s frames' % len(frames)
" 2>/dev/null; then
  ok "JSON con frames de amplitud ($(wc -c < "$_t/ad.json") bytes)"
else
  falla "extract-audio-data.py no produjo datos utilizables (numpy/ffmpeg)"
fi

debe_reprobar "contrast-report.mjs sin argumentos se niega" \
  node "$D/scripts/contrast-report.mjs"

paso "presets, paletas y templates con contenido"
PRE=$(find "$D/frame-presets" -mindepth 1 -maxdepth 1 -type d | wc -l)
PAL=$(find "$D/palettes" -type f -size +50c | wc -l)
TPL=$(find "$D/templates" -type f -size +50c | wc -l)
if [ "$PRE" -ge 10 ] && [ "$PAL" -ge 1 ] && [ "$TPL" -ge 1 ]; then ok "$PRE presets, $PAL paletas, $TPL templates"; else falla "presets=$PRE paletas=$PAL templates=$TPL"; fi
rm -rf "$_t"
cierra
