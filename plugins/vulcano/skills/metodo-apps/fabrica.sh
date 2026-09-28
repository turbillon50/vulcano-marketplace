#!/bin/bash
# FÁBRICA DE APPS — un comando arma el loop completo del Método de apps (skills-vault/metodo-apps).
# Uso: /root/fabrica.sh <nombre> <nuevo|rescate> <repo-git-url> "<lo que pidió Luis, literal>"
set -e
N="$1"; MODO="$2"; REPO="$3"; PIDIO="$4"
[ -z "$N" ] || [ -z "$MODO" ] || [ -z "$REPO" ] && { echo "uso: fabrica.sh <nombre> <nuevo|rescate> <repo> \"<pedido literal>\""; exit 1; }
W=/root/worktrees/$N-f1; C=$(echo "$N" | tr a-z A-Z)
[ -d "$W" ] || git clone -q "$REPO" "$W"
cd "$W"; git checkout -q -B fabrica
V=/root/skills-vault
cat > BRIEF-F1.md <<B
# BRIEF F1: $N ($MODO) — Método de apps

Repo \`$W\`, rama \`fabrica\`. Node 20 (nvm). Commits firmados turbillon50 <turbillon50@gmail.com>.

## Lo que pidió Luis (literal)
$PIDIO

## Antes de tocar código (obligatorio)
1. Lee COMPLETOS: \`$V/metodo-apps/SKILL.md\` (el método), \`$V/pwa-agencia-premium/SKILL.md\` (carga/ícono/animación 4k con Higgsfield), \`$V/pwa-checklist/SKILL.md\` y \`$V/vulcano-design-protocol/SKILL.md\` si existen.
2. Estándares vivos: \`curl\`/Brain (memorias del proyecto) y el README del repo.
3. Si MODO=rescate: ejecuta §2 del método y escribe \`RESCATE.md\` ANTES de cambiar nada.

## Las 7 lentes (\`$V/metodo-apps/LENTES.md\`)
- MODO=nuevo: pasa las lentes 1→5 ANTES de programar y deja su salida en \`LISTA.md\`, \`COPY.md\` y \`motion.css\`; la 6 con la app en producción; la 7 al cerrar (\`LANZAMIENTO.md\`).
- MODO=rescate: \`RESCATE.md\` → lente 6 sobre lo que hay → 1→5 solo sobre lo que se decidió rehacer → 7 al cerrar.
- Una lente que solo produjo prosa no cuenta: cada una termina en renglones con criterio medible.

## Cómo trabajas
- Sigues el método §3→§7 en orden. Fuente de verdad: \`LISTA.md\` (en la raíz); [x] solo con ruta en producción + captura WebKit MIRADA; [LUIS] lo que solo él puede hacer.
- Push al cerrar cada bloque. Al terminar la lista, re-auditas la app completa y agregas lo nuevo.
- \`DONE-F1\` solo cuando todo esté en [x] salvo [LUIS]. Reporte final en \`REPORTE-F1.md\`.
B
cp $V/metodo-apps/LISTA-PLANTILLA.md LISTA.md 2>/dev/null || true
cat > /root/sup-$N.sh <<S
#!/bin/bash
cd $W || exit 0
exec 9>/root/.sup-$N.lock; flock -n 9 || exit 0
export NVM_DIR=/root/.nvm; . \$NVM_DIR/nvm.sh >/dev/null; nvm use 20 >/dev/null
while [ ! -f DONE-F1 ]; do
  date +"[$C] %m-%d %H:%M" >> supervisor.log
  env IS_SANDBOX=1 HOME=/root PLAYWRIGHT_BROWSERS_PATH=/dev/shm/trama-conversations-browser claude -p "\$(cat BRIEF-F1.md)" --dangerously-skip-permissions --output-format text >> BRIEF-F1.md.log 2>&1
  sleep 30
done
S
chmod +x /root/sup-$N.sh
(crontab -l 2>/dev/null | grep -v "sup-$N.sh"; echo "*/10 * * * * /root/sup-$N.sh >/dev/null 2>&1") | crontab -
nohup /root/sup-$N.sh >/dev/null 2>&1 &
echo "FABRICA $N lista: worktree $W · supervisor /root/sup-$N.sh · log $W/BRIEF-F1.md.log"
