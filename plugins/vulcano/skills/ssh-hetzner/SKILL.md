---
name: ssh-hetzner
version: 2.0
description: Entrar al servidor Hetzner v-forge y recuperar los servicios cuando el relay no responde. ACTIVAR cuando el relay este caido, brain/exec de 5xx, o haya que operar el servidor a mano.
---
# SSH Hetzner v-forge

Servidor: **178.105.135.26** (cpx62, 16 vCPU / 32 GB).

## Entrar
```
ssh root@178.105.135.26
```
O por consola web: console.hetzner.com -> v-forge -> boton Console (>_).

## CORREGIDO 2-oct-2026 — los servicios ya NO viven en pm2
La version 1.0 de esta skill mandaba a `pm2 start /home/server.py --name brain-relay`.
Eso ya no funciona: ese archivo no existe y brain-relay migro a systemd. Medido hoy.

| servicio | donde vive | puerto | codigo |
|---|---|---|---|
| `brain-relay.service` | systemd | 9000 | `/home/brain-relay.py` |
| `v-server.service` | systemd | 5000 | `/home/v-server/api.py` |
| `mesh-mcp.service` | systemd | 8089 | `/root/mesh-router/mesh_mcp.py` |
| `neon-mcp.service` | systemd | 12014 | `/root/neon-mcp/server.py` |

En pm2 quedan apps, no infraestructura: catalogo-crystal, catalogo-compoentes,
vforge-live-ojo, esteticar-api, leads-app, hetzner-mcp, mcp-watchdog, playwright-mcp.

## Comprobar que esta vivo
```
systemctl is-active brain-relay v-server mesh-mcp neon-mcp
curl -s http://localhost:5000/health        # v-server -> {"status":"healthy","version":2}
curl -s http://localhost:9000/health        # brain-relay
pm2 list                                    # las apps
```

## Si el relay no responde
```
systemctl restart brain-relay.service
journalctl -u brain-relay.service -n 50 --no-pager   # LEE el error antes de reintentar
```
No repetir el restart a ciegas: el candado anti-bucle (`/etc/systemd/system/service.d/vl-limites.conf`)
marca el servicio como failed si truena 5 veces en 10 minutos.

## Si `brain.vforge.site/brain/exec` da 401
Es correcto: exige el secret en el cuerpo. 401 **no** es que este caido.
Un 5xx si es caida; un 000 es que no hay nada escuchando.

## Trampas del servidor
- El executor corre `/bin/sh`, NO bash: no hay expansion de llaves `{a,b}` ni `<(...)`.
  Para eso, `bash -lc "..."` o escribir el script a un archivo y ejecutarlo.
- Node 20: `export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh; nvm use 20`
- El cache de npm es un symlink a `/dev/shm`, que se borra en cada reinicio.
  Lo recrea `/etc/tmpfiles.d/npm-cache-ram.conf`. Si npm da ENOTDIR, revisa eso.

## Estructura
```
/home/secrets/global/.env     llaves (OJO: varias variables por linea, un grep arrastra vecinas)
/root/credenciales/           llaves nuevas, una por archivo, modo 600
/home/brain-relay.py          el relay
/home/v-server/api.py         el API Flask del 5000
/root/skills-vault/           el arsenal (repo turbillon50/skills-vault)
```
