#!/usr/bin/env bash
# Verifica que el protocolo de agencia premium sea APLICABLE hoy: CLI de
# Higgsfield con sesion, ffmpeg con webp, WebKit real para mirar con ojos de
# navegador (no Chrome, que da falsos verdes), y el splash de produccion vivo.
. /root/skills-vault/_lib/verif.sh
echo "verificando pwa-agencia-premium"
export HOME=/root

paso "Higgsfield CLI con sesion"
if higgsfield account status >/dev/null 2>&1; then ok "autenticado"; else falla "sin sesion (higgsfield account login)"; fi

# TRAMPA: `ffmpeg -encoders | grep -q libwebp` da exit 141 (SIGPIPE) cuando hay
# pipefail: grep -q cierra el pipe al primer match, ffmpeg muere con SIGPIPE y
# pipefail propaga ESE codigo. Da falso negativo. Y leer la lista de encoders
# tampoco prueba que el encoder funcione: aqui se genera un webp de verdad.
paso "ffmpeg genera un webp de verdad"
_t=$(mktemp -d)
ffmpeg -hide_banner -loglevel error -f lavfi -i color=c=red:s=32x32:d=1 -frames:v 1 "$_t/p.webp" >/dev/null 2>&1
if [ -s "$_t/p.webp" ]; then ok "$(wc -c < "$_t/p.webp") bytes"; else falla "ffmpeg no pudo codificar webp"; fi
rm -rf "$_t"

# OJO: la version anterior buscaba webkit en /dev/shm/trama-conversations-browser,
# y /dev/shm SE BORRA EN CADA REINICIO. Por eso esta skill aparecia ROTA sin
# estarlo. Los browsers viven en disco; se respeta PLAYWRIGHT_BROWSERS_PATH.
paso "WebKit disponible (la regla: WebKit, no Chrome)"
WB="${PLAYWRIGHT_BROWSERS_PATH:-/root/pw-browsers}"
WK=$(find "$WB" /root/.cache/ms-playwright -maxdepth 2 -name pw_run.sh -path '*webkit*' 2>/dev/null | head -1)
if [ -n "$WK" ]; then ok "$(dirname "$WK" | xargs basename)"; else falla "no hay webkit en $WB ni en ~/.cache/ms-playwright"; fi

# OJO: Next.js le pone hash de build a los assets (mobile.28e1ccaa.mp4), asi que
# pedir /carga/mobile.webp a pelo SIEMPRE da 404. Hay que leer la ruta del HTML.
paso "el splash de produccion sirve sus assets"
HTML=$(curl -s --max-time 25 https://vmomentum.site)
A=$(printf '%s' "$HTML" | grep -oE '/carga/[a-zA-Z0-9_.-]+\.(webp|mp4|jpg|png)' | sort -u | head -1)
if [ -z "$A" ]; then
  printf 'FALLA: el HTML de produccion no referencia ningun asset de /carga\n'; _fallos=$((_fallos+1))
else
  n=$(printf '%s' "$HTML" | grep -oE '/carga/[a-zA-Z0-9_.-]+\.(webp|mp4|jpg|png)' | sort -u | wc -l)
  c=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 "https://vmomentum.site$A")
  case "$c" in 2*) ok "$n assets referenciados, el primero ($A) da $c";;
    *) printf 'FALLA: %s da HTTP %s\n' "$A" "$c"; _fallos=$((_fallos+1));; esac
fi

debe_reprobar "un asset inventado de /carga da 404" \
  curl -sf --max-time 12 "https://vmomentum.site/carga/no-existe-zz99.webp"
cierra
