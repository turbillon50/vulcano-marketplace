#!/bin/bash
cd "$(dirname "$0")" && out=$(timeout 60 python3 scripts/search.py "beauty spa wellness service" --design-system -p "Prueba" 2>&1) || { echo "search.py falló: ${out:0:200}"; exit 1; }
[ ${#out} -gt 200 ] || { echo "salida vacía"; exit 1; }
echo "OK: ui-ux-pro-max genera sistema de diseño (${#out} chars)"
