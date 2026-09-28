---
name: infra-monitor
description: Monitoreo en tiempo real de GitHub repos y Vercel deployments. ACTIVAR cuando el usuario diga "status", "como van mis proyectos", "revisa GitHub", "revisa Vercel", "que hay en produccion", "ultimo deploy", "repos", o cuando cualquier agente necesite verificar el estado actual de la infraestructura.
---
# Infra Monitor — GitHub + Vercel en tiempo real

## GitHub (via API)
Token: leer de ~/.git-credentials en Hetzner o usar relay
Base: https://api.github.com

### Listar repos
GET /users/turbillon50/repos?per_page=100&sort=updated

### Ultimo commit de un repo
GET /repos/turbillon50/{repo}/commits?per_page=1

### Ver branches
GET /repos/turbillon50/{repo}/branches

## Vercel (via API)
Team: team_gK8RSuGh0CYHEjgEqFRR2iIk
Base: https://api.vercel.com

### Listar proyectos
GET /v9/projects?teamId=team_gK8RSuGh0CYHEjgEqFRR2iIk

### Ultimo deployment
GET /v6/deployments?projectId={ID}&teamId=team_gK8RSuGh0CYHEjgEqFRR2iIk&limit=1

### Env vars de un proyecto
GET /v10/projects/{ID}/env?teamId=team_gK8RSuGh0CYHEjgEqFRR2iIk

## Via relay (si red restringida)
POST http://178.105.135.26/brain/exec con cmd que ejecute los curls

## Formato de reporte
| Proyecto | Repo | Ultimo commit | Deploy | Status |
|---|---|---|---|---|
| V-Gift | turbillon50/v-gift | hace X min | production | ready/error |
