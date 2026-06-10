---
name: code-review
description: Supervisor de calidad de codigo. ACTIVAR cuando un agente Claude Code termine una tarea (antes de declararla hecha), cuando el usuario diga "revisa el code", "supervisa", "valida lo que hizo", "esta bien lo que armo", "verifica el trabajo", o cuando se vaya a mergear/deployar. Verifica el resultado CONTRA LA REALIDAD (compila, tipos, hizo la tarea, sin inventos, demo!=app) y da veredicto APROBADO/RECHAZADO. Ningun trabajo se da por bueno sin pasar esta revision.
---

# Code Review — Supervisor de calidad

Antes de declarar una tarea "hecha", PASA por esta revision. Nada se da por bueno sin verificar contra la realidad.

## Como ejecutar
```
node /root/agents/supervisor/review.js <ruta-del-repo> "lo que debia hacer la tarea" --full
```
(`--full` instala y compila; sin el, solo revisa el diff + veredicto rapido)

## Rubrica (lo que se revisa)
1. **Hizo la tarea** — el diff resuelve lo que se pidio, no algo aledano.
2. **Compila** — `npm run build` pasa; sin errores de tipos.
3. **Sin inventos** — no usa imports/APIs/archivos que no existen (alucinacion).
4. **demo != app** — si era demo: ligera, sin auth/DB/pagos. Si era app: stack real.
5. **Nada a medias** — sin botones muertos, sin TODOs criticos, sin console.errors.

## Salida
`VEREDICTO: APROBADO | RECHAZADO` + problemas + accion. Se manda a WhatsApp de Luis y se guarda en reviews.json.

## Regla de oro
Si no se verifico contra la realidad, NO esta hecho. El agente que no pasa review, corrige y vuelve a pasar.
