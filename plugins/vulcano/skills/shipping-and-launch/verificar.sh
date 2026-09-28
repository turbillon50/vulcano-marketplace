#!/bin/bash
# Verificacion de skill de documentacion (sin credenciales ni red).
cd "$(dirname "$0")"
n=$(basename "$PWD")
[ -f SKILL.md ] || { echo "falta SKILL.md"; exit 1; }
head -1 SKILL.md | grep -q '^---$' || { echo "SKILL.md sin frontmatter"; exit 1; }
fm=$(awk 'NR==1{next} /^---$/{exit} {print}' SKILL.md)
nm=$(printf '%s\n' "$fm" | sed -n 's/^name:[[:space:]]*//p' | head -1 | tr -d '"')
[ "$nm" = "$n" ] || { echo "name '$nm' no coincide con carpeta '$n'"; exit 1; }
printf '%s\n' "$fm" | grep -q '^description:' || { echo "sin description"; exit 1; }
[ -f LICENSE ] || { echo "falta LICENSE del upstream"; exit 1; }
[ -f ORIGEN.md ] || { echo "falta ORIGEN.md"; exit 1; }
[ -d .git ] && { echo "trae .git adentro"; exit 1; }
faltan=""
for ref in $(grep -oE '\((\./)?references/[A-Za-z0-9._/-]+\)' SKILL.md | tr -d '()' | sed 's#^\./##' | sort -u); do
  [ -e "$ref" ] || faltan="$faltan $ref"
done
[ -z "$faltan" ] || { echo "referencias rotas:$faltan"; exit 1; }
grep -q '^## Adaptacion Vulcano' SKILL.md || { echo "sin seccion Adaptacion Vulcano"; exit 1; }
echo "OK: $n frontmatter valido, $(wc -l < SKILL.md) lineas, referencias completas"
