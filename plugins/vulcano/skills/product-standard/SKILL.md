---
name: product-standard
description: Estandarizacion de Producto de la FABRICA. Define el ESQUELETO OBLIGATORIO que TODO producto debe llevar antes de salir: (a) vistas de contexto/publico, (b) PANEL DE CONTROL Y ADMINISTRACION funcional de verdad, y (c) CANAL DE COMUNICACION real entre usuario y admin. Hornea la leccion de Crede-ti: el admin recibe en TIEMPO REAL + correo, da retroalimentacion al usuario, y lleva notas/seguimiento — nada de push fragil suelto. ACTIVAR cuando el usuario diga "producto", "estandariza", "esqueleto", "panel admin", "administracion", "comunicacion usuario admin", "que no le falte nada", "checklist de producto", "product-standard", o despues de context-min cuando ya hay contexto y toca definir el esqueleto. Es el SEGUNDO modulo del pipeline (context-min -> system-intel -> product-standard -> design-library -> total-supervision). Consume el contexto de context-min desde el Brain.
version: 1.0
agents: [Vulcano]
triggers: [producto, estandariza, esqueleto, panel admin, administracion, comunicacion usuario admin, checklist de producto, product-standard, que no le falte nada]
---

# product-standard — Estandarizacion de Producto

Segundo eslabon de la FABRICA. Toma el `{contexto}` de **context-min** y le inyecta el **esqueleto obligatorio** sin el cual NINGUN producto sale.

> Regla de oro: **no sale sin panel admin real + canal de comunicacion real.** Lo demas es decorado.

---

## Conexion al Brain

```
Relay exec (bash):  POST http://178.105.135.26/brain/exec   body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):  POST http://178.105.135.26/brain/query  body {"secret":"superclaude2025","query":"..."}
```
Una sentencia SQL por query. Relay re-entrante: scripts en Hetzner NO llaman al relay.

---

## ENTRADA
El `{contexto}` que dejo `context-min` en `projects`:
```
SELECT id,name,stack,phase,next_step FROM projects WHERE id='andromeda'
```

## SALIDA
El `{contexto}` enriquecido con el **esqueleto obligatorio** (las tres capas A/B/C abajo), listo para que `design-library` le ponga estilo.

---

## EL ESQUELETO OBLIGATORIO (las 3 capas)

### (A) Vistas de contexto / publico
- Landing/hero que explica el giro (vibe lo decide design-library).
- Catalogo / vitrina / contenido publico segun giro.
- Onboarding o entrada (Clerk magic-link, entrada libre en demos).
- 3 modos navegables: **publico / usuario / admin** con toggle flotante (no tapa el nav — ver v3 en design-library).

### (B) PANEL DE CONTROL Y ADMINISTRACION (funcional de verdad)
NO es un dashboard de adorno. Debe poder:
- Ver y gestionar usuarios, pedidos/solicitudes, contenido (CRUD real contra Neon).
- Ver metricas reales de la DB (no numeros hardcodeados).
- Cambiar estados (aprobar, rechazar, marcar, avanzar etapa) y que el cambio se refleje al usuario.
- Bandeja de entrada del admin (lo que entra del usuario, abajo capa C).

### (C) COMUNICACION usuario <-> admin (VITAL — leccion Crede-ti)
La parte que mas se rompe si se hace mal. Obligatorio:
- **Admin recibe en TIEMPO REAL** (registro en Neon + canal en vivo) **Y por CORREO** (Resend). El correo es el respaldo duro — no se confia solo en push del navegador, que es fragil.
- **Retroalimentacion al usuario**: el admin responde y el usuario VE la respuesta dentro del producto (estado + mensaje), no solo un "gracias".
- **Notas / seguimiento**: el admin lleva notas internas e historial por usuario/solicitud (tabla de seguimiento en Neon).
- Canal real (mensajes persistidos en DB), no un push suelto que se pierde al recargar.

---

## CHECKLIST "NO SALE SIN ESTO"

- [ ] 3 modos navegables publico/usuario/admin + toggle flotante que no tapa nav.
- [ ] Panel admin con **CRUD real** contra Neon (no mocks).
- [ ] Metricas del admin leidas de la DB real.
- [ ] Admin recibe solicitudes en **tiempo real** (Neon) **+ correo Resend**.
- [ ] Usuario VE la retroalimentacion del admin dentro del producto.
- [ ] **Notas/seguimiento** por usuario persistidas en Neon.
- [ ] Canal de comunicacion persistido (no push fragil).
- [ ] Datos demo plausibles sembrados.

Si algo de esto falta -> **el producto NO esta listo**, regresa al build. Esta lista la verifica luego `total-supervision`.

---

## LA LECCION CREDE-TI (horneada)

Crede-ti fallo porque la comunicacion usuario<->admin dependia de push fragil del navegador: el admin no se enteraba a tiempo y el usuario quedaba sin respuesta. **Fix permanente:** todo producto de la fabrica lleva, por defecto, registro en Neon en tiempo real + correo Resend al admin + retroalimentacion visible al usuario + notas de seguimiento. Esto ya NO se decide por proyecto: es estandar.

```
INSERT INTO lessons (project_id,type,area,lesson,fix,source)
VALUES ('crede-ti','fail','comunicacion','push del navegador es fragil, el admin no se entera y el usuario queda sin respuesta','estandar: Neon tiempo real + correo Resend + retro visible + notas seguimiento','product-standard')
```

---

## HANDOFF / PIPELINE

```
context-min -> [product-standard: + esqueleto A/B/C] -> design-library -> total-supervision
```

- **Consume** el `{contexto}` de `context-min`.
- **Produce** el contexto + esqueleto obligatorio y actualiza el Brain:
  ```
  UPDATE projects SET phase='esqueleto', next_step='design-library', last_agent='product-standard', updated_at=now() WHERE id='andromeda'
  ```
- **Entrega** a `design-library` para que elija la ficha de diseno.
- El checklist de arriba es el contrato que `total-supervision` exige verde antes de liberar.
