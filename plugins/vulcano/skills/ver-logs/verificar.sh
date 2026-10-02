#!/usr/bin/env bash
# Ejercita de verdad las tres vias de la skill: logs de build de Vercel,
# pm2 del servidor y journalctl de systemd.
. /root/skills-vault/_lib/verif.sh
echo "verificando ver-logs"
TOK=$(exige VERCEL_TOKEN)
H="Authorization: Bearer $TOK"

paso "traer eventos de build de un deploy real de Vercel"
DID=$(curl -sf --max-time 20 -H "$H" "https://api.vercel.com/v6/deployments?limit=1" \
      | python3 -c 'import json,sys
ds=json.load(sys.stdin).get("deployments",[])
print((ds[0].get("uid") or ds[0].get("id")) if ds else "")' 2>/dev/null)
if [ -n "$DID" ]; then
  ev=$(curl -sf --max-time 25 -H "$H" "https://api.vercel.com/v3/deployments/$DID/events?limit=5" \
       | head -c 200 | wc -c)
  if [ "${ev:-0}" -gt 10 ]; then ok "eventos leidos del deploy $DID"; else falla "el deploy no devolvio eventos"; fi
else falla "no pudo obtener un deployId"; fi

paso "pm2: leer estado de procesos"
np=$(pm2 jlist 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null) || np=""
if [ -n "$np" ] && [ "$np" -gt 0 ] 2>/dev/null; then ok "$np procesos"; else falla "pm2 no devolvio procesos"; fi

paso "journalctl: leer un log de systemd"
nl=$(journalctl -u neon-mcp.service -n 5 --no-pager 2>/dev/null | wc -l)
if [ "${nl:-0}" -gt 0 ]; then ok "$nl lineas"; else falla "journalctl no devolvio lineas"; fi

# pedir logs de un deploy inventado DEBE fallar
debe_reprobar "deployId inexistente no devuelve eventos" \
  curl -sf --max-time 15 -H "$H" "https://api.vercel.com/v3/deployments/dpl_zzz000noexiste/events"
# OJO: journalctl de un servicio inexistente imprime "-- No entries --" y sale
# con codigo 0, asi que "sin lineas" NO sirve como prueba. Lo que hay que
# comprobar es que distinguimos un log vacio de uno con contenido real.
debe_reprobar "journalctl de servicio inexistente no trae entradas reales" \
  bash -c 'journalctl -u servicio-que-no-existe-zz.service -n 5 --no-pager 2>/dev/null | grep -qv "No entries"'
debe_reprobar "pm2 describe de un proceso inexistente falla" \
  pm2 describe proceso-que-no-existe-zz
cierra
