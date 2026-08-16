---
name: vercel-operator
version: 1.0
description: Operador seguro de Vercel para Luis/Vulcano. Usa el MCP propio de Vercel con credenciales almacenadas en servidor; nunca imprime tokens. Sirve para inspeccionar proyectos, deployments, variables por nombre, logs, inyectar env vars y redeployar previews. Produccion requiere confirmacion explicita para promover, rollback o acciones destructivas.
triggers:
  - "vercel"
  - "deploy"
  - "deployment"
  - "preview"
  - "variables de entorno"
  - "env vars"
  - "logs de vercel"
  - "publica a produccion"
---
# Vercel Operator

## Principio
Chat/agent -> Vulcano -> Vercel MCP -> Vercel API/CLI. La credencial vive en `/root/vercel-mcp/vercel-mcp.env` y nunca debe copiarse a prompts, respuestas, repositorios ni archivos de skill.

## Flujo normal
1. Identificar proyecto exacto.
2. Inspeccionar deployments y estado.
3. Revisar nombres de env vars sin revelar valores.
4. Para cambios de codigo, crear/probar Preview primero.
5. Revisar logs/errores.
6. Solo promover/rollback/produccion con instruccion explicita de Luis.

## Acciones seguras sin confirmacion adicional
- listar proyectos
- listar deployments
- listar nombres de env vars
- inspeccionar deployment
- leer logs de build/runtime
- crear o actualizar env var cuando Luis haya entregado explicitamente el valor o la tarea requiera una credencial ya disponible en el secret store
- redeploy de preview cuando no altera el dominio productivo

## Acciones que requieren instruccion explicita
- promover a produccion
- rollback de produccion
- borrar proyecto/deployment/dominio/env var
- cambiar dominios productivos

## Seguridad
- Nunca devolver valores de secretos.
- Nunca registrar tokens en Brain, logs de chat o Git.
- En reportes de env vars mostrar solo key + targets.
- Antes de produccion verificar READY y revisar errores recientes.
- Mantener trazabilidad de proyecto, deployment y resultado.
