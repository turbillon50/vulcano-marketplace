#!/usr/bin/env bash
# Ejercita de verdad: comprueba que los servicios que la skill nombra existen
# y responden. Si la skill nombrara servicios inexistentes (como hacia la v1),
# este verificador reprueba.
. /root/skills-vault/_lib/verif.sh
echo "verificando ssh-hetzner"

paso "los servicios systemd que documenta la skill estan activos"
malos=""
for s in brain-relay v-server mesh-mcp neon-mcp; do
  [ "$(systemctl is-active "$s" 2>/dev/null)" = "active" ] || malos="${malos:+$malos }$s"
done
[ -z "$malos" ] && ok "brain-relay v-server mesh-mcp neon-mcp" || falla "no activos: $malos"

paso "v-server responde en :5000/health"
h=$(curl -s --max-time 10 http://localhost:5000/health 2>/dev/null)
printf '%s' "$h" | grep -q healthy && ok "$h" || falla "respuesta inesperada: ${h:-vacia}"

paso "los archivos que documenta la skill existen"
faltan=""
for f in /home/brain-relay.py /home/v-server/api.py /root/mesh-router/mesh_mcp.py; do
  [ -f "$f" ] || faltan="${faltan:+$faltan }$f"
done
[ -z "$faltan" ] && ok "3 de 3" || falla "no existen: $faltan"

paso "pm2 responde y lista procesos"
np=$(pm2 jlist 2>/dev/null | python3 -c 'import json,sys; print(len(json.load(sys.stdin)))' 2>/dev/null) || np=""
if [ -n "$np" ] && [ "$np" -gt 0 ] 2>/dev/null; then ok "$np procesos"; else falla "pm2 no respondio"; fi

# un servicio que no existe NO debe dar active (si diera, no distinguiriamos)
debe_reprobar "servicio inexistente no esta active" \
  bash -c 'test "$(systemctl is-active servicio-que-no-existe-zz 2>/dev/null)" = active'
debe_reprobar "puerto sin nada escuchando no da health" \
  curl -sf --max-time 5 http://localhost:59999/health
cierra
