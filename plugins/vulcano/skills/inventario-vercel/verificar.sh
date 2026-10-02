#!/usr/bin/env bash
# Ejercita de verdad: lista proyectos de Vercel por API y clasifica uno.
. /root/skills-vault/_lib/verif.sh
echo "verificando inventario-vercel"
TOK=$(exige VERCEL_TOKEN)
H="Authorization: Bearer $TOK"

paso "listar proyectos por API"
n=$(curl -sf --max-time 20 -H "$H" "https://api.vercel.com/v9/projects?limit=100" \
    | python3 -c 'import json,sys; print(len(json.load(sys.stdin).get("projects",[])))' 2>/dev/null) || n=""
if [ -n "$n" ] && [ "$n" -gt 0 ] 2>/dev/null; then ok "$n proyectos"; else falla "no devolvio proyectos"; fi

paso "clasificar el primero (dominios + ultimo deploy)"
curl -sf --max-time 20 -H "$H" "https://api.vercel.com/v9/projects?limit=1" -o /tmp/_iv.json 2>/dev/null
cls=$(python3 - <<'PY' 2>/dev/null
import json
p=json.load(open('/tmp/_iv.json'))['projects'][0]
tiene=bool(p.get('targets',{}).get('production'))
print(('VIVO' if tiene else 'SIN-PRODUCCION')+':'+p['name'])
PY
)
[ -n "$cls" ] && ok "$cls" || falla "no pudo clasificar"

# un projectId inventado DEBE dar error: si no, el arnes no distingue
debe_reprobar "projectId inexistente da 404" \
  curl -sf --max-time 15 -H "$H" "https://api.vercel.com/v9/projects/proyecto-que-no-existe-zz99"
cierra
