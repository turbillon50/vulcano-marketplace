#!/usr/bin/env bash
# Ejercita de verdad las dos vias de la skill: GitHub API y Vercel API con el
# teamId que la propia skill documenta.
. /root/skills-vault/_lib/verif.sh
echo "verificando infra-monitor"
TEAM=team_gK8RSuGh0CYHEjgEqFRR2iIk
VT=$(exige VERCEL_TOKEN)

paso "GitHub: listar repos de turbillon50"
GT=$(grep -hm1 -oE 'ghp_[A-Za-z0-9]+|github_pat_[A-Za-z0-9_]+' /root/.git-credentials 2>/dev/null | head -1)
if [ -z "$GT" ]; then
  printf 'FALLA: no hay token de GitHub en /root/.git-credentials\n'; _fallos=$((_fallos+1))
else
  nr=$(curl -sf --max-time 25 -H "Authorization: Bearer $GT" \
       "https://api.github.com/user/repos?per_page=100&sort=updated" \
       | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null) || nr=""
  if [ -n "$nr" ] && [ "$nr" -gt 0 ] 2>/dev/null; then ok "$nr repos"; else falla "GitHub no devolvio repos"; fi
fi

paso "Vercel: listar proyectos con el teamId que documenta la skill"
np=$(curl -sf --max-time 25 -H "Authorization: Bearer $VT" \
     "https://api.vercel.com/v9/projects?teamId=$TEAM&limit=100" \
     | python3 -c 'import json,sys; print(len(json.load(sys.stdin).get("projects",[])))' 2>/dev/null) || np=""
if [ -n "$np" ] && [ "$np" -gt 0 ] 2>/dev/null; then ok "$np proyectos en $TEAM"; else falla "el teamId de la skill no devolvio proyectos"; fi

paso "Vercel: ultimo deployment de un proyecto del team"
PID=$(curl -sf --max-time 25 -H "Authorization: Bearer $VT" "https://api.vercel.com/v9/projects?teamId=$TEAM&limit=1" \
      | python3 -c 'import json,sys
ps=json.load(sys.stdin).get("projects",[]); print(ps[0]["id"] if ps else "")' 2>/dev/null)
if [ -n "$PID" ]; then
  st=$(curl -sf --max-time 25 -H "Authorization: Bearer $VT" \
       "https://api.vercel.com/v6/deployments?projectId=$PID&teamId=$TEAM&limit=1" \
       | python3 -c 'import json,sys
ds=json.load(sys.stdin).get("deployments",[])
print((ds[0].get("readyState") or ds[0].get("state")) if ds else "")' 2>/dev/null)
  [ -n "$st" ] && ok "estado del ultimo deploy: $st" || falla "no devolvio deployments"
else falla "no pudo tomar un projectId del team"; fi

debe_reprobar "teamId inventado no devuelve proyectos" \
  curl -sf --max-time 15 -H "Authorization: Bearer $VT" "https://api.vercel.com/v9/projects?teamId=team_zzz000noexiste&limit=1"
cierra
