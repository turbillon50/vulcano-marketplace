#!/usr/bin/env bash
# Ejercita de verdad: comprueba que la cadena de build funciona en este servidor
# y, sobre todo, que un build ROTO SI se detecta. La skill dice "sin build verde
# no se declara nada"; esto verifica que de hecho se puede saber.
. /root/skills-vault/_lib/verif.sh
echo "verificando build-verde-o-no-existe"

# OJO (medido 2-oct-2026): `. $NVM_DIR/nvm.sh` SE CUELGA en contexto no
# interactivo (sin TTY), asi que el patron documentado de Node 20 NO sirve
# dentro de un verificador ni en cron. Se usa el binario directo.
# Ademas el node del sistema es v18, no v20: sin este PATH se compila con 18.
NB=$(ls -d /root/.nvm/versions/node/v20*/bin 2>/dev/null | head -1)
[ -n "$NB" ] || bloqueada "no hay Node 20 instalado en /root/.nvm/versions/node/v20*"
export PATH="$NB:$PATH"

paso "node 20 disponible (sin sourcear nvm)"
v=$(node -v 2>/dev/null)
case "$v" in v20.*) ok "$v";; "") falla "node no responde";; *) falla "node es $v, la regla pide 20";; esac

paso "npm responde (cache sano)"
# /root/.npm es symlink a /dev/shm, que se vacia en cada reinicio; lo recrea
# /etc/tmpfiles.d/npm-cache-ram.conf. Si esto falla con ENOTDIR, revisa eso.
nv=$(npm -v 2>/dev/null)
[ -n "$nv" ] && ok "npm $nv" || falla "npm roto (si dice ENOTDIR: el cache en /dev/shm no existe, ver /etc/tmpfiles.d/npm-cache-ram.conf)"

D=$(mktemp -d)
paso "un build VERDE se detecta como verde"
printf '%s' '{"name":"t","version":"1.0.0","scripts":{"build":"node -e \"process.exit(0)\""}}' > "$D/package.json"
if (cd "$D" && npm run build >/dev/null 2>&1); then ok "exit 0"; else falla "un build que debia pasar, fallo"; fi

paso "un build ROJO se detecta como rojo"
printf '%s' '{"name":"t","version":"1.0.0","scripts":{"build":"node -e \"process.exit(1)\""}}' > "$D/package.json"
if (cd "$D" && npm run build >/dev/null 2>&1); then
  falla "un build que debia fallar, paso -> no se podria distinguir verde de rojo"
else ok "exit distinto de 0"; fi

paso "con pipefail el fallo no se enmascara tras un pipe"
# La trampa que documenta Luis: sin pipefail, el exit code tras un pipe es del
# ULTIMO comando (tail), que casi siempre devuelve 0, y un build rojo "pasa".
if (cd "$D" && set -o pipefail; npm run build 2>&1 | tail -3 >/dev/null); then
  falla "con pipefail, un build rojo seguido de tail dio exito"
else ok "pipefail propaga el fallo"; fi

paso "SIN pipefail el fallo SI se enmascara (demuestra por que importa)"
if (cd "$D" && set +o pipefail; npm run build 2>&1 | tail -3 >/dev/null); then
  ok "confirmado: sin pipefail el build rojo pasa desapercibido"
else falla "se esperaba que sin pipefail el fallo quedara oculto"; fi

rm -rf "$D"
cierra
