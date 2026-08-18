#!/bin/bash
set -a; . /root/.env 2>/dev/null; . /home/secrets/global/.env 2>/dev/null; set +a
c=$(timeout 20 curl -s -o /dev/null -w '%{http_code}' https://api.vercel.com/v2/user -H "Authorization: Bearer $VERCEL_TOKEN")
[ "$c" = "200" ] || { echo "Vercel API -> $c"; exit 1; }
n=$(timeout 20 curl -s "https://api.vercel.com/v9/projects?limit=5" -H "Authorization: Bearer $VERCEL_TOKEN" | grep -o '"name"' | wc -l)
[ "$n" -gt 0 ] || { echo "no pudo listar proyectos"; exit 1; }
echo "OK: Vercel responde y lista proyectos"
