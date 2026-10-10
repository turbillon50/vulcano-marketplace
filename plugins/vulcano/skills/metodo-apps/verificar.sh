#!/usr/bin/env bash
# Verifica que EL METODO este servible HOY: los 5 documentos de la ley
# (SKILL, MUST-500, SANIDAD, LENTES, LISTA-PLANTILLA) con contenido real —
# no solo existencia, du dice si tienen algo — y que fabrica.sh compile y
# pida sus argumentos sin efectos secundarios (nada de clonar ni agendar).
. /root/skills-vault/_lib/verif.sh
echo "verificando metodo-apps"
D=$(cd "$(dirname "$0")" && pwd)

paso "los 5 documentos de la ley existen y traen contenido"
falta=""
for f in SKILL.md MUST-500.md SANIDAD.md LENTES.md LISTA-PLANTILLA.md; do
  [ -s "$D/$f" ] || falta="$falta $f"
done
if [ -z "$falta" ]; then
  ok "$(wc -l < "$D/SKILL.md") + $(wc -l < "$D/MUST-500.md") + $(wc -l < "$D/SANIDAD.md") + $(wc -l < "$D/LENTES.md") lineas"
else
  falla "vacios o ausentes:$falta"
fi

# Existencia no es contenido (regla 6): MUST-500 se llama 500 porque tiene ~500
# obviedades numeradas. Si alguien la vacio, la skill miente.
paso "MUST-500 trae sus obviedades numeradas"
n=$(grep -cE '^[0-9]+\. ' "$D/MUST-500.md")
if [ "$n" -ge 450 ]; then ok "$n items numerados"; else falla "solo $n items numerados (deberian ser ~500)"; fi

paso "fabrica.sh compila (bash -n)"
if bash -n "$D/fabrica.sh" 2>"$D/.bashn.err"; then rm -f "$D/.bashn.err"; ok "sintaxis valida"; else falla "$(cat "$D/.bashn.err")"; rm -f "$D/.bashn.err"; fi

paso "fabrica.sh sin argumentos pide el uso y sale 1 (sin clonar nada)"
OUT=$(timeout 10 bash "$D/fabrica.sh" 2>&1); RC=$?
if [ "$RC" -eq 1 ] && printf '%s' "$OUT" | grep -q 'uso:'; then ok "guard de argumentos vivo"
else falla "salio $RC sin el uso: $OUT"; fi

debe_reprobar "fabrica.sh exige el repo aunque nombre y modo vengan" \
  timeout 10 bash "$D/fabrica.sh" prueba rescate

paso "LISTA-PLANTILLA trae renglones verificables"
n=$(grep -cE '^\s*[-*] \[' "$D/LISTA-PLANTILLA.md")
[ "$n" -ge 40 ] && ok "$n renglones" || falla "solo $n renglones en la plantilla"
cierra
