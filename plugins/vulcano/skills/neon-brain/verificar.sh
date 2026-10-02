#!/usr/bin/env bash
# Ejercita de verdad: lee el Brain, escribe una memoria de prueba, la relee y
# la borra. Si cualquier paso falla, la memoria persistente no sirve.
. /root/skills-vault/_lib/verif.sh
echo "verificando neon-brain"
RUN=/root/vulcano-audit/run.sh
[ -x "$RUN" ] || bloqueada "no existe $RUN (es la via de SQL al Brain)"

q() { printf '%s\n' "$1" > /tmp/_nb.sql; "$RUN" /tmp/_nb.sql 2>&1; }

paso "leer: contar tablas del Brain"
n=$(q "SELECT count(*) FROM information_schema.tables WHERE table_schema='public';" | grep -oE '^[0-9]+$' | head -1)
if [ -n "$n" ] && [ "$n" -gt 50 ] 2>/dev/null; then ok "$n tablas"; else falla "devolvio '${n:-nada}' (se esperaban >50)"; fi

paso "leer: las tablas clave existen"
t=$(q "SELECT count(*) FROM information_schema.tables WHERE table_schema='public' AND table_name IN ('memory','lessons','projects','skill_verificacion');" | grep -oE '^[0-9]+$' | head -1)
[ "$t" = "4" ] && ok "memory lessons projects skill_verificacion" || falla "solo $t de 4 tablas clave"

MARCA="verif-neon-brain-$$-$(date +%s)"
paso "escribir: insertar una memoria de prueba"
q "INSERT INTO memory (agent,type,topic,content) VALUES ('V','note','$MARCA','prueba del verificador de neon-brain');" >/dev/null
r=$(q "SELECT count(*) FROM memory WHERE topic='$MARCA';" | grep -oE '^[0-9]+$' | head -1)
[ "$r" = "1" ] && ok "insertada y releida" || falla "no se pudo releer lo escrito (count=${r:-nada})"

paso "limpiar: borrar la memoria de prueba"
q "DELETE FROM memory WHERE topic='$MARCA';" >/dev/null
r2=$(q "SELECT count(*) FROM memory WHERE topic='$MARCA';" | grep -oE '^[0-9]+$' | head -1)
[ "$r2" = "0" ] && ok "limpiada" || falla "quedo basura en memory: $MARCA"

# OJO: run.sh corre psql con ON_ERROR_STOP=0, asi que un SQL malo devuelve el
# error como TEXTO y sale con codigo 0. Por eso no sirve como debe_reprobar:
# hay que comprobar que la salida trae el error, no que el comando falle.
paso "una tabla inexistente devuelve error (el Brain no inventa resultados)"
err=$(q "SELECT 1 FROM tabla_que_no_existe_zz;")
if printf '%s' "$err" | grep -qiE 'does not exist|no existe|ERROR'; then
  ok "devolvio error como se esperaba"
else
  falla "una consulta invalida NO devolvio error (salida: $(printf '%s' "$err" | head -c 80))"
fi
cierra
