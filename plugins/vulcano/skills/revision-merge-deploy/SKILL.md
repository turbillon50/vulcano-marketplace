---
name: revision-merge-deploy
description: Revisar ramas y Pull Requests abiertos de un repo, triar cuales mergear, juntarlos a main UNO POR UNO con build+deploy, y limpiar ramas obsoletas. La razon #1 por la que una app se ve estancada aunque haya mucho trabajo es que el trabajo quedo en ramas/PRs sin mergear. ACTIVAR cuando Luis diga revisa los PRs, hay ramas sin mergear, se ve igual/estancado/igual o peor, junta el trabajo, mergea y despliega, limpia ramas, no veo mejoras.
---
# Revision de merge y deploy (juntar el trabajo atorado)

## Por que importa (la causa del desmadre)
El codigo VIVO en internet = la rama main desplegada. Si el trabajo se hizo en OTRAS ramas (o lo hizo v0/un agente en una copia) y nunca se mergeo a main + deploy, entonces la mejora EXISTE pero NO esta publicada -> la app se ve igual. Acumular ramas sin mergear = el desmadre.

## Pasos
1. Lista PRs abiertos y ramas: GET /repos/<owner>/<repo>/pulls?state=open y /branches.
2. Por cada PR: que hace, sigue VIGENTE o ya lo supero main, choca con lo current.
3. Test-merge sin romper: git checkout -b test main && git merge --no-commit --no-ff origin/<rama>. Conflicto trivial -> resolver a favor de lo current. Refactor grande disruptivo -> NO mergear a ciegas; marcar para decision del dueño.
4. Mergear SOLO los que: vigentes + merge limpio + npm run build OK + aportan. UNO a la vez, con deploy READY entre cada uno (para aislar si algo rompe).
5. Commit firmado con la cuenta DEL TEAM de Vercel (si no, el deploy sale BLOCKED).
6. Si un merge rompe produccion -> rollback inmediato (skill rollback).
7. Cerrar PRs/ramas obsoletas para dejar limpio.
8. Entregar tabla: MERGEADO / CERRADO-OBSOLETO / PENDIENTE-DECISION, con razon. Documentar en brain.

## Regla
Un merge a la vez + verificar en vivo. Nunca merge-a-todo a lo bestia (se rompe mas).
