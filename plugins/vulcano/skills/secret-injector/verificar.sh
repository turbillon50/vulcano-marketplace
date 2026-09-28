#!/bin/bash
set -a; . /root/.env 2>/dev/null; set +a
c=$(timeout 20 curl -s -o /dev/null -w '%{http_code}' https://api.vercel.com/v2/user -H "Authorization: Bearer $VERCEL_TOKEN")
[ "$c" = "200" ] || { echo "sin acceso a Vercel -> $c"; exit 1; }
[ -f /root/.env ] || { echo "no encuentra almacen de secretos"; exit 1; }
echo "OK: puede leer secretos y alcanzar Vercel"
