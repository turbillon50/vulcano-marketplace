---
name: rollback
description: Regresar una app a su ultima version BUENA cuando un cambio la rompio. ACTIVAR cuando Luis diga rollback, regresa, revierte, se rompio, estaba bien antes, vuelve a la version buena, deshaz, o cuando un deploy quede en ERROR/BLOCKED o una app deje de funcionar tras un cambio.
---
# Rollback — volver a la version buena

Nada se pierde: git guarda CADA version y Vercel guarda CADA deploy. Roto != perdido.

## A) Rollback de Vercel (lo mas rapido, sin tocar codigo)
1. Identifica el ultimo deployment de PRODUCCION en estado READY ANTES del malo: GET https://api.vercel.com/v6/deployments?projectId=<PID>&teamId=<TEAM>&target=production&limit=20 (Bearer VERCEL_TOKEN). Busca el ultimo readyState=READY bueno y su `meta.githubCommitSha`.
2. Promuevelo (Instant Rollback): en el dashboard Vercel -> Deployments -> el bueno -> ... -> Promote to Production; o por API promueve ese deployment. El dominio vuelve al build bueno en segundos.

## B) Rollback de git (revertir el codigo)
1. `git log --oneline` para ver los commits; identifica el ultimo commit bueno (o usa el `githubCommitSha` del deploy READY bueno).
2. Revertir SIN perder historial: `git revert <commit_malo>` (crea un commit que deshace). O volver a un punto: `git checkout <commit_bueno> -- <archivos>` para archivos puntuales.
3. push a main -> Vercel redeploya. Verifica READY.

## Reglas
- SIEMPRE verifica EN VIVO en el navegador del usuario tras el rollback.
- Prefiere revert sobre reset --hard en main (no reescribir historia compartida).
- Documenta en el brain `cierre-<app>` que se hizo rollback y a que commit.
- Si el deploy quedo BLOCKED por tope de gasto de Vercel: eso no es codigo, es billing del usuario (Settings -> Billing).
