#!/bin/bash
# Verifica que el protocolo sea aplicable: CLI de Higgsfield autenticado, ffmpeg con webp, WebKit disponible.
ok=0
export HOME=/root
higgsfield account status >/dev/null 2>&1 && echo "higgsfield: OK" || { echo "higgsfield: SIN SESION"; ok=1; }
ffmpeg -hide_banner -encoders 2>/dev/null | grep -q libwebp && echo "ffmpeg libwebp: OK" || { echo "ffmpeg libwebp: FALTA"; ok=1; }
ls /dev/shm/trama-conversations-browser/webkit-*/pw_run.sh >/dev/null 2>&1 && echo "webkit: OK" || { echo "webkit: FALTA"; ok=1; }
curl -s -o /dev/null -w '%{http_code}' https://vmomentum.site/carga/mobile.webp | grep -q 200 && echo "prod carga: OK" || { echo "prod carga: FALLA"; ok=1; }
exit $ok

