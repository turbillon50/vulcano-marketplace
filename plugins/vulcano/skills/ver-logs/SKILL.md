---
name: ver-logs
description: Leer logs para diagnosticar por que algo falla, sin adivinar. ACTIVAR cuando Luis diga ve los logs, que dice el error, por que falla, revisa logs, no jala, da error, o cuando haya que diagnosticar un deploy/app/servidor.
---
# Ver logs — diagnosticar con evidencia, no adivinando

## Vercel (build y runtime)
- Build log de un deploy: por el MCP de Vercel get_deployment_build_logs, o API GET https://api.vercel.com/v3/deployments/<dplId>/events (Bearer VERCEL_TOKEN). Aqui salen errores de compilacion.
- Runtime logs (errores en vivo de las funciones): get_runtime_logs del MCP de Vercel.
- Estado del deploy: GET /v13/deployments/<id> -> readyState (READY/ERROR/BLOCKED).

## Hetzner (servidor 178.105.135.26) via POST /brain/exec
- App/PM2: `pm2 logs <name> --lines 80` o `pm2 list`.
- systemd: `journalctl -u <servicio> -n 80 --no-pager`.
- Logs de tareas Claude Code: `tail -n 100 /home/<tarea>.log`.
- Relay/brain: revisar server.py / brain-relay.

## Navegador (Claude in Chrome)
- Consola: read_console_messages (pattern=error). Red: read_network_requests (ver 401/403/500/redirects).
- Health de la app: GET /api/health.

## Regla
- Primero LEE el log y cita el error textual; luego arregla la causa. Nunca "a ver si con esto".
