---
name: build-verde-o-no-existe
description: Verificar antes de declarar cualquier trabajo terminado. ACTIVAR antes de decir listo, hecho o terminado.
---

npm run build 2>&1 | tail -6 -- sin build verde no se declara nada.
Desplegar, esperar ~3 min al edge, verificar la URL real, no el local.

Trampas conocidas:
- CSS Modules rechaza selectores de atributo sueltos: usar .clase :global([data-x])
- ref es palabra reservada de React: nunca como nombre de prop
- Antes de sobrescribir un endpoint: git show HEAD:<ruta> para ver que hacia
