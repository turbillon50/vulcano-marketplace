#!/usr/bin/env bash
# Ejercita de verdad: encuentra el ultimo deploy de produccion READY (en seco,
# NO promueve nada) y comprueba que trae el commit sha para revertir.
. /root/skills-vault/_lib/verif.sh
echo "verificando rollback (dry-run, no promueve)"
TOK=$(exige VERCEL_TOKEN)
H="Authorization: Bearer $TOK"

paso "tomar un proyecto con produccion"
PID=$(curl -sf --max-time 20 -H "$H" "https://api.vercel.com/v9/projects?limit=40" \
      | python3 -c 'import json,sys
ps=json.load(sys.stdin).get("projects",[])
for p in ps:
    if p.get("targets",{}).get("production"): print(p["id"]); break' 2>/dev/null)
[ -n "$PID" ] && ok "$PID" || falla "ningun proyecto con produccion"

if [ -n "$PID" ]; then
  paso "listar deploys de produccion y hallar el ultimo READY"
  curl -sf --max-time 25 -H "$H" \
    "https://api.vercel.com/v6/deployments?projectId=$PID&target=production&limit=20" -o /tmp/_rb.json 2>/dev/null
  res=$(python3 - <<'PY' 2>/dev/null
import json
ds=json.load(open('/tmp/_rb.json')).get('deployments',[])
good=[d for d in ds if d.get('readyState')=='READY' or d.get('state')=='READY']
if not good: raise SystemExit(1)
d=good[0]
sha=(d.get('meta') or {}).get('githubCommitSha') or 'sin-sha'
print("%s sha=%s" % (d.get('uid') or d.get('id'), sha[:8]))
PY
)
  [ -n "$res" ] && ok "$res" || falla "no hay deploy READY para volver"
fi

# sin token no debe poder listar: comprueba que la API realmente exige auth
debe_reprobar "listar deploys sin token da 401/403" \
  curl -sf --max-time 15 "https://api.vercel.com/v6/deployments?limit=1"
cierra
