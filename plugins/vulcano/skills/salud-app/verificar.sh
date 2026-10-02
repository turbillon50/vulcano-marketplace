#!/usr/bin/env bash
# Ejercita de verdad los chequeos de la skill contra una app en produccion:
# deploy READY en Vercel, DNS resolviendo, HTTP vivo y manifest de PWA.
. /root/skills-vault/_lib/verif.sh
APP="${1:-vmomentum.site}"
echo "verificando salud-app contra $APP"
TOK=$(exige VERCEL_TOKEN)
H="Authorization: Bearer $TOK"

# OJO: consultar /v6/deployments?target=production SIN filtrar por proyecto
# devuelve los deploys de TODA la cuenta y siempre da verde, para cualquier
# dominio. Hay que hallar el proyecto que sirve ESTE dominio y mirar el suyo.
paso "Vercel: el proyecto que sirve $APP tiene produccion READY"
curl -sf --max-time 30 -H "$H" "https://api.vercel.com/v9/projects?limit=100" -o /tmp/_sa.json 2>/dev/null
res=$(APP="$APP" python3 - <<'PY' 2>/dev/null
import json,os
dom=os.environ["APP"]
ps=json.load(open("/tmp/_sa.json")).get("projects",[])
hit=[]
for q in ps:
    t=(q.get("targets") or {}).get("production") or {}
    if dom in (t.get("alias") or []): hit.append((q["name"], t.get("readyState")))
if not hit: raise SystemExit(1)
ready=[h for h in hit if h[1]=="READY"]
extra=(" | OJO: %d proyectos reclaman el dominio: %s" % (len(hit), ", ".join(h[0] for h in hit))) if len(hit)>1 else ""
if not ready: print("NOREADY:%s%s" % (hit[0][0], extra)); raise SystemExit(2)
print("%s=%s%s" % (ready[0][0], ready[0][1], extra))
PY
)
case "$res" in
  "")        falla "ningun proyecto de Vercel sirve $APP (o no esta en los primeros 100)";;
  NOREADY:*) falla "el proyecto existe pero su produccion NO esta READY -> ${res#NOREADY:}";;
  *)         ok "$res";;
esac

paso "DNS: $APP resuelve"
ips=$(dig +short "$APP" A 2>/dev/null | grep -cE '^[0-9]+\.') || ips=0
if [ "${ips:-0}" -gt 0 ]; then ok "$ips registro(s) A"; else falla "$APP no resuelve a ninguna IP"; fi

paso "HTTP: $APP responde"
code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 20 -L "https://$APP") || code=000
case "$code" in 2*|3*) ok "HTTP $code";; *) falla "HTTP $code";; esac

# OJO: NO asumir /manifest.json. Un navegador lee <link rel="manifest"> del HTML
# y pide esa ruta; hay apps que usan /manifest.webmanifest. Asumirlo daba un
# falso rojo en vmomentum.site, que tiene la PWA perfectamente bien.
paso "PWA: manifest declarado en el HTML y accesible"
MREF=$(curl -s --max-time 20 -L "https://$APP" \
  | grep -oE '<link[^>]*rel="?manifest"?[^>]*>' \
  | grep -oE 'href="[^"]+"' | head -1 | cut -d'"' -f2)
if [ -z "$MREF" ]; then
  printf 'FALLA: el HTML no declara <link rel="manifest">\n'; _fallos=$((_fallos+1))
else
  case "$MREF" in http*) MURL="$MREF";; /*) MURL="https://$APP$MREF";; *) MURL="https://$APP/$MREF";; esac
  mc=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 -L "$MURL") || mc=000
  case "$mc" in 2*) ok "$MREF -> HTTP $mc";; *) printf 'FALLA: %s da HTTP %s\n' "$MREF" "$mc"; _fallos=$((_fallos+1));; esac
fi

paso "PWA: service worker"
sw=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 -L "https://$APP/sw.js") || sw=000
sw2=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 -L "https://$APP/service-worker.js") || sw2=000
case "$sw$sw2" in *200*) ok "sw presente (sw.js:$sw service-worker.js:$sw2)";; *) printf 'FALLA: no hay service worker (sw.js:%s service-worker.js:%s)\n' "$sw" "$sw2"; _fallos=$((_fallos+1));; esac

paso "contenido real (no pantalla de error, no pagina vacia)"
body=$(curl -s --max-time 25 -L "https://$APP") || body=""
blen=${#body}
titulo=$(printf '%s' "$body" | grep -oiE '<title[^>]*>[^<]*' | head -1 | sed 's/.*>//' | cut -c1-60)
if [ "$blen" -lt 500 ]; then
  printf 'FALLA: la pagina devuelve solo %s bytes (sospecha de pagina vacia)\n' "$blen"; _fallos=$((_fallos+1))
elif printf '%s' "$body" | grep -qiE 'DEPLOYMENT_NOT_FOUND|404: NOT_FOUND|This Serverless Function has crashed|Application error'; then
  printf 'FALLA: la pagina responde 200 pero muestra un error de Vercel\n'; _fallos=$((_fallos+1))
else
  ok "${blen} bytes | titulo: ${titulo:-sin titulo}"
fi

# un dominio inventado NO debe resolver ni responder
debe_reprobar "dominio inexistente no resuelve" \
  bash -c 'test -n "$(dig +short zz-no-existe-vulcano-9931.site A 2>/dev/null | grep -E "^[0-9]+\.")"'
debe_reprobar "dominio inexistente no da HTTP 2xx" \
  curl -sf --max-time 10 "https://zz-no-existe-vulcano-9931.site"
cierra
