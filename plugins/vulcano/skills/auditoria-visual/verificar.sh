#!/bin/bash
python3 -c "from playwright.sync_api import sync_playwright" 2>/dev/null || { echo "playwright no instalado"; exit 1; }
python3 - <<'PY' 2>/dev/null || { echo "no pudo capturar pantalla"; exit 1; }
from playwright.sync_api import sync_playwright
with sync_playwright() as p:
    b=p.webkit.launch(); pg=b.new_page(viewport={"width":390,"height":844})
    pg.goto("https://vliving.site", timeout=45000)
    pg.screenshot(path="/tmp/_av.png"); b.close()
PY
[ -s /tmp/_av.png ] || { echo "captura vacia"; exit 1; }
echo "OK: captura pantalla real en movil ($(stat -c%s /tmp/_av.png) bytes)"
