---
name: ssh-hetzner
version: 1.0
description: Conectarse al servidor Hetzner v-forge via SSH. ACTIVAR cuando el relay esta caido.
---
# SSH Hetzner v-forge

## Conectarse desde PowerShell
ssh root@178.105.135.26

## Desde consola web Hetzner
1. console.hetzner.com
2. Click en v-forge
3. Boton Console (>_)

## Comandos al entrar
pm2 list
pm2 restart all
pm2 logs brain-relay --lines 50
curl -s http://localhost:5000/health
systemctl restart nginx

## Si relay da 403
pm2 list -> ver si brain-relay esta online
pm2 start /home/server.py --name brain-relay
systemctl restart nginx

## Estructura /home/
boot-context.md, prompt-arranque.md
secrets/global/.env (todas las keys)
skills-vault/ (copia local)
server.py (relay Flask puerto 5000)

## pm2 procesos esperados
brain-relay, goossip, goossip-scheduler
