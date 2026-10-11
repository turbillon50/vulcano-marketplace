# PROMESAS — [pantalla]

Cada elemento interactivo visible promete algo. Si no puede cumplirlo, no se dibuja.
Formato inventado por los agentes de TRATTO (PROMESAS.md), ahora ley de la fábrica.

| id | Pantalla | Elemento | Requiere sesión | Promesa | Consecuencia | Prueba |
|---|---|---|---|---|---|---|
| P-001 | / | Entrar | no | Navega a /sign-in | … | Manual / e2e |

Reglas:
1. Toda promesa se PRUEBA antes de servir (manual o automatizada; "debería funcionar" no es prueba).
2. Un elemento deshabilitado se etiqueta honesto en pantalla ("disponible cuando…") — nunca falso activo.
3. Este archivo se actualiza en el MISMO commit que la pantalla.
