---
name: graphify-setup
description: Instalar y correr Graphify en cualquier repo para crear knowledge graph y ahorrar tokens. ACTIVAR cuando se clone un repo nuevo, se inicie un proyecto, o Claude Code gaste muchos tokens releyendo archivos. Estándar para todos los proyectos.
---
# Graphify — Knowledge Graph para ahorrar tokens

## Qué es
Convierte un codebase en un grafo queryable. Claude Code consulta el grafo en vez de leer archivos crudos. Ahorro: 5x-15x tokens por sesión.

## Instalación (ya hecho en Hetzner)
pip install graphifyy openai --break-system-packages
graphify install  # registra skill en Claude Code

## Uso estándar para cada proyecto nuevo
cd /tmp/{repo} && export $(grep GEMINI /home/secrets/global/.env) && graphify . --no-viz
graphify cluster-only .

## Output
graphify-out/graph.json — grafo queryable
graphify-out/GRAPH_REPORT.md — reporte de arquitectura
graphify-out/graph.html — visualización interactiva

## Actualizar después de cambios
graphify update .  # sin costo de API, solo AST

## Grafos ya generados
| Proyecto | Nodos | Edges | Comunidades |
|---|---|---|---|
| Ruta 618 | 1,158 | 2,945 | 65 |
| RideMe | 795 | 1,444 | 50 |
| CSN (mitcan) | 271 | 471 | 30 |

## Reglas
- Correr en CADA repo nuevo al clonarlo
- Actualizar después de merges grandes
- Usar Gemini como backend (más barato)
- Costo típico: $0.08-0.15 por repo
