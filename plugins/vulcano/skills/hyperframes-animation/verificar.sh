#!/usr/bin/env bash
# Verifica hyperframes-animation HOY. OJO: los tests vendidos asumen el
# layout del monorepo hyperframes (buscan <repo>/skills/... y el pin de
# version del package.json raiz) — desde el vault no pueden correr tal cual.
# Este arnes prueba el COMPORTAMIENTO real con las rutas del vault:
# animation-map.mjs capturando con fps racional 30000/1001 contra un
# productor falso, el rechazo de fps ambiguo, la paridad byte-a-byte del
# package-loader con hyperframes-creative, y el catalogo con contenido.
. /root/skills-vault/_lib/verif.sh
echo "verificando hyperframes-animation"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
CREATIVE=$(cd "$D/../hyperframes-creative" 2>/dev/null && pwd)
P=$(mktemp -d)

paso "animation-map.mjs captura con fps racional 30000/1001 (productor falso)"
mkdir -p "$P/node_modules/@hyperframes/producer" "$P/node_modules/@hyperframes/core" "$P/node_modules/sharp" "$P/comp"
printf '%s' '{"name":"@hyperframes/producer","type":"module","exports":"./index.mjs"}' > "$P/node_modules/@hyperframes/producer/package.json"
cat > "$P/node_modules/@hyperframes/producer/index.mjs" <<'J'
export async function createFileServer(o) {
  const { readFileSync } = await import("node:fs");
  const html = readFileSync(o.compiledDir + "/index.html", "utf8");
  if (html !== "<!doctype html><main>bundled modular composition</main>") throw new Error("UNEXPECTED_BUNDLE=" + html);
  return { url: "http://test", close() {} };
}
export async function createCaptureSession(_u, _o, options) { throw new Error("CAPTURE_OPTIONS=" + JSON.stringify(options)); }
export async function initializeSession() {}
export async function closeCaptureSession() {}
export async function getCompositionDuration() { return 0; }
J
printf '%s' '{"name":"@hyperframes/core","type":"module","exports":{".":"./index.mjs","./compiler":"./compiler.mjs"}}' > "$P/node_modules/@hyperframes/core/package.json"
cat > "$P/node_modules/@hyperframes/core/index.mjs" <<'J'
export function parseFps(i) {
  if (i === "30000/1001") return { ok: true, value: { num: 30000, den: 1001 } };
  if (i === "29.97") return { ok: false, reason: "ambiguous-decimal" };
  return { ok: true, value: { num: Number(i), den: 1 } };
}
J
printf '%s' 'export async function bundleToSingleHtml() { return "<!doctype html><main>bundled modular composition</main>"; }' > "$P/node_modules/@hyperframes/core/compiler.mjs"
printf '%s' '{"name":"sharp","type":"module","exports":"./index.mjs"}' > "$P/node_modules/sharp/package.json"
printf '%s' 'export default function sharp() {}' > "$P/node_modules/sharp/index.mjs"
OUT=$(HYPERFRAMES_SKILL_NODE_MODULES="$P/node_modules" node "$D/scripts/animation-map.mjs" "$P/comp" --fps 30000/1001 --out "$P/out" 2>&1); RC=$?
if [ "$RC" -ne 0 ] && printf '%s' "$OUT" | grep -q 'CAPTURE_OPTIONS=.*"fps":{"num":30000,"den":1001}'; then
  ok "el mapa sale con fps racional"
else
  falla "no capturo con fps racional (rc=$RC): $(printf '%s' "$OUT" | head -1)"
fi

paso "(debe reprobar) fps ambiguo 29.97 se rechaza sin llegar a capturar"
OUT2=$(HYPERFRAMES_SKILL_NODE_MODULES="$P/node_modules" node "$D/scripts/animation-map.mjs" "$P/comp" --fps 29.97 --out "$P/out2" 2>&1); RC2=$?
if [ "$RC2" -ne 0 ] && printf '%s' "$OUT2" | grep -q 'Invalid --fps "29.97": ambiguous-decimal' && ! printf '%s' "$OUT2" | grep -q CAPTURE_OPTIONS; then
  printf 'reprobo como se esperaba\n'
else
  printf 'MAL: 29.97 paso (rc=%s) — el guard de fps no sirve\n' "$RC2"; _fallos=$((_fallos+1))
fi

paso "package-loader.mjs identico byte-a-byte al de hyperframes-creative (contrato declarado)"
if [ -n "$CREATIVE" ] && cmp -s "$D/scripts/package-loader.mjs" "$CREATIVE/scripts/package-loader.mjs"; then
  ok "copias gemelas"
else
  falla "las copias divergieron (o falta hyperframes-creative al lado)"
fi

paso "catalogo de movimiento con contenido (reglas, blueprints, transitions, adapters)"
R=$(find "$D/rules" -name '*.md' -size +100c 2>/dev/null | wc -l)
B=$(find "$D/blueprints" -name '*.md' -size +100c 2>/dev/null | wc -l)
T=$(find "$D/transitions" -name '*.md' -size +100c 2>/dev/null | wc -l)
A=$(find "$D/adapters" -name '*.md' -size +100c 2>/dev/null | wc -l)
if [ "$R" -ge 30 ] && [ "$B" -ge 5 ] && [ "$T" -ge 3 ] && [ "$A" -ge 7 ]; then
  ok "$R reglas, $B blueprints, $T transitions, $A adapters"
else
  falla "reglas=$R blueprints=$B transitions=$T adapters=$A (el catalogo vino incompleto)"
fi

paso "los indices citan el catalogo que existe"
IB=$(grep -c '<blueprint id=' "$D/blueprints-index.md" 2>/dev/null)
IR=$(grep -cE 'rules/[a-z0-9-]+\.md' "$D/rules-index.md" 2>/dev/null)
[ "${IB:-0}" -ge 20 ] && [ "${IR:-0}" -ge 30 ] && ok "blueprints-index $IB, rules-index cita $IR reglas" \
  || falla "blueprints-index=$IB, rules-index=$IR (indices desincronizados del catalogo)"
rm -rf "$P"
cierra
