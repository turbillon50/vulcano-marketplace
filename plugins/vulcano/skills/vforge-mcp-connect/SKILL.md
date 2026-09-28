---
name: vforge-mcp-connect
version: 1.0
description: Conectar VForge MCP en cualquier Claude, Dispatch o Cowork. Una sola skill resuelve todo el flujo OAuth y la conexion manual. ACTIVAR cuando VForge no aparece en conectores, cuando se pierde la conexion, o al configurar un Claude nuevo.
---
# VForge MCP — Conexion en cualquier lado

## DATOS FIJOS (no cambian)
URL MCP:      https://vforge.site/api/mcp
Token Bearer: vfmcp_10731b2b8eee26a32b8dc97d855bbaa19c97c68c77d7c527
Client ID:    claude-ai
Client Secret: vfs_3b4f948860a999edc679cc35d032abbfbbd34966371e41df

OAuth URLs:
  Authorize: https://vforge.site/api/oauth/authorize
  Token:     https://vforge.site/api/oauth/token

## OPCION 1 — Claude Desktop (Cowork)
1. Abrir Claude Desktop
2. Cowork → Customize → Conectores → Add
3. Poner URL: https://vforge.site/api/mcp
4. Cuando pida OAuth usar los datos de arriba
5. Si da error "client_id desconocido" → correr migracion (ver abajo)

## OPCION 2 — Manual con Bearer token
En cualquier Claude que acepte headers MCP:
  Authorization: Bearer vfmcp_10731b2b8eee26a32b8dc97d855bbaa19c97c68c77d7c527

## OPCION 3 — Desde terminal Hetzner
curl -X POST https://vforge.site/api/mcp   -H "Content-Type: application/json"   -H "Authorization: Bearer vfmcp_10731b2b8eee26a32b8dc97d855bbaa19c97c68c77d7c527"   -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}'

## SI DA ERROR "client_id desconocido"
Significa que la migracion 014 no corrio. Ejecutar:
curl -X POST https://vforge.site/api/admin/migrate   -H "Authorization: Bearer f6517612a657137095f7b32af26f87750d338ba9fc80245a9f7814399c5e1ca6"

## SI DA ERROR "unauthorized" en migrate
El middleware de Clerk esta bloqueando. Verificar que
/api/admin(.*) este en rutas publicas de middleware.ts

## TOOLS DISPONIBLES (14)
- vforge_scaffold_project: arma proyecto completo de una
- vforge_create_repo: crea repo GitHub
- vforge_deploy: despliega en Vercel
- vforge_project_status: estado de todos los proyectos
- vforge_payments: financiero de clientes
- vforge_execute_skill: ejecuta cualquier skill
- vforge_recommend_stack: recomienda stack
- vforge_brain_search: busca en memoria
- vforge_skill_list: lista skills disponibles
- vforge_integration_plan: plan de integraciones
- vforge_apps_health: salud de apps
- getting_started, vforge_method, help (publicas)

## VERIFICAR QUE FUNCIONA
curl -X POST https://vforge.site/api/mcp   -H "Authorization: Bearer vfmcp_10731b2b8eee26a32b8dc97d855bbaa19c97c68c77d7c527"   -H "Content-Type: application/json"   -d '{"jsonrpc":"2.0","id":1,"method":"tools/list","params":{}}' | python3 -m json.tool
Debe devolver 14 tools.
