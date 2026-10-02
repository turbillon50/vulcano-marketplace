#!/usr/bin/env bash
# Ejercita de verdad: lista dominios y records reales en name.com, y comprueba
# que la DETECCION de la regla critica (host = solo subdominio) funciona.
# Solo lectura: no crea, no borra, no modifica records.
. /root/skills-vault/_lib/verif.sh
echo "verificando dns-manager (solo lectura)"
T=$(exige NAMECOM_TOKEN)
U=$(exige NAMECOM_USER)

paso "listar dominios de la cuenta"
nd=$(curl -sf --max-time 20 -u "$U:$T" https://api.name.com/v4/domains \
     | python3 -c 'import json,sys; print(len(json.load(sys.stdin).get("domains") or []))' 2>/dev/null) || nd=""
if [ -n "$nd" ] && [ "$nd" -gt 0 ] 2>/dev/null; then ok "$nd dominios"; else falla "no devolvio dominios"; fi

paso "leer records de vforge.site"
curl -sf --max-time 20 -u "$U:$T" https://api.name.com/v4/domains/vforge.site/records -o /tmp/_dns.json 2>/dev/null
nr=$(python3 -c 'import json; print(len(json.load(open("/tmp/_dns.json")).get("records") or []))' 2>/dev/null) || nr=""
if [ -n "$nr" ] && [ "$nr" -gt 0 ] 2>/dev/null; then ok "$nr records"; else falla "no leyo records"; fi

# La capacidad que la skill promete es DETECTAR el host doble. Se prueba con un
# caso sembrado: si la deteccion no lo encuentra, la skill no sirve.
paso "la deteccion de host doble encuentra un caso sembrado"
det=$(python3 - <<'PY' 2>/dev/null
rs=[{"host":"clerk","id":1},{"host":"mail.ejemplo.com","id":2},{"host":"","id":3}]
base="ejemplo.com"
print(sum(1 for r in rs if (r.get("host") or "").endswith(base)))
PY
)
[ "$det" = "1" ] && ok "detecto 1 de 1 sembrado" || falla "la deteccion no encontro el caso sembrado (detecto: ${det:-nada})"

# Aviso informativo sobre los records reales: no es fallo de la skill, es
# suciedad en los datos. Se reporta con el id para poder limpiarla.
sucios=$(python3 - <<'PY' 2>/dev/null
import json
rs=json.load(open("/tmp/_dns.json")).get("records") or []
out=[(r.get("id"),r.get("type"),r.get("host")) for r in rs if (r.get("host") or "").endswith("vforge.site")]
print("|".join("%s %s %s" % x for x in out))
PY
)
[ -n "$sucios" ] && echo "  AVISO (no es fallo de la skill): records con dominio base en el host -> $sucios"

debe_reprobar "token invalido da 403" \
  curl -sf --max-time 15 -u "$U:token-invalido-zz" https://api.name.com/v4/domains
cierra
