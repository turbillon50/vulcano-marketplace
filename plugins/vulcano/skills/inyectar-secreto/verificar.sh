#!/bin/bash
set -a; . /root/.env 2>/dev/null; set +a
c=$(timeout 20 curl -s -o /dev/null -w '%{http_code}' https://api.vercel.com/v2/user -H "Authorization: Bearer $VERCEL_TOKEN")
[ "$c" = "200" ] || { echo "sin Vercel -> $c"; exit 1; }
echo "OK: puede inyectar variables en Vercel"
