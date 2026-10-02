#!/usr/bin/env bash
# Ejercita de verdad: el endpoint MCP de VForge responde a un initialize con el
# token que documenta la skill. Si el token murio, esto reprueba.
. /root/skills-vault/_lib/verif.sh
echo "verificando vforge-mcp-connect"
URL=https://vforge.site/api/mcp
TK=$(grep -m1 -oE 'vfmcp_[0-9a-f]+' /root/skills-vault/vforge-mcp-connect/SKILL.md | head -1)
[ -n "$TK" ] || bloqueada "la SKILL.md no trae el token Bearer (vfmcp_...)"

INIT='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"verificador","version":"1"}}}'

paso "el endpoint MCP responde al initialize con el token"
c=$(curl -s -o /tmp/_vf.json -w '%{http_code}' --max-time 25 -X POST "$URL" \
     -H "Authorization: Bearer $TK" -H 'Content-Type: application/json' \
     -H 'Accept: application/json, text/event-stream' -d "$INIT")
case "$c" in
  200) ok "HTTP 200";;
  401|403) falla "el token de la SKILL.md ya no sirve (HTTP $c) -> hay que renovarlo en la skill";;
  000) falla "no hubo respuesta de $URL";;
  *)   falla "HTTP $c inesperado";;
esac

paso "la respuesta es MCP valida (trae serverInfo o result)"
if grep -qE '"result"|serverInfo|protocolVersion' /tmp/_vf.json 2>/dev/null; then
  ok "handshake MCP correcto"
else
  falla "respondio pero no es MCP: $(head -c 100 /tmp/_vf.json)"
fi

paso "las URLs de OAuth que documenta la skill existen"
oa=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 https://vforge.site/api/oauth/authorize)
case "$oa" in 2*|3*|4*) ok "authorize responde $oa (no 000)";; *) falla "authorize no responde (HTTP $oa)";; esac

debe_reprobar "token invalido es rechazado" \
  bash -c 'c=$(curl -s -o /dev/null -w "%{http_code}" --max-time 15 -X POST https://vforge.site/api/mcp -H "Authorization: Bearer vfmcp_invalido_zz" -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d "{\"jsonrpc\":\"2.0\",\"id\":1,\"method\":\"initialize\",\"params\":{\"protocolVersion\":\"2024-11-05\",\"capabilities\":{},\"clientInfo\":{\"name\":\"t\",\"version\":\"1\"}}}"); test "$c" = "200"'
cierra
