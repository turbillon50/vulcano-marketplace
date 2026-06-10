---
name: spec-maxima
description: Spec de Funcionamiento Maximo de la FABRICA. Dado un proyecto (su giro + lo que YA existe), GENERA automaticamente un documento contrato "Spec de Funcionamiento Maximo" que define COMO debe funcionar la app al maximo, modulo por modulo, sin que Luis tenga que dar las cosas detalle por detalle. Clasifica PRODUCCION (dominio propio + datos reales -> premium funcional, quirurgico, guantes de seda, cero cambios agrestes) vs DEMO (libre). Por cada modulo/rol del giro define: que hace al maximo, flujos completos end-to-end, que datos lleva, que es official vs placeholder. Hornea el estandar de calidad (5 puntos), admin dinamico + white-label, comunicacion usuario<->admin, y (si aplica al giro) recompensas/soporte. Define lo que se considera "terminado al maximo". Se guarda en el Brain y se vuelve el CONTRATO: Luis lo aprueba UNA vez y Vulcano construye hacia eso sin pedir detalle por detalle. ACTIVAR cuando el usuario diga "como debe funcionar", "spec maxima", "funcionamiento maximo", "que deberia hacer", "definicion completa", "el maximo de la app", "contrato de la app", o entre system-intel y product-standard. TERCER eslabon del pipeline (context-min -> system-intel -> spec-maxima -> product-standard -> design-library -> total-supervision).
version: 1.0
agents: [Vulcano]
triggers: [como debe funcionar, spec maxima, funcionamiento maximo, que deberia hacer, definicion completa, el maximo de la app, contrato de la app]
---

# spec-maxima — Spec de Funcionamiento Maximo

Tercer eslabon de la FABRICA. Se mete ENTRE `system-intel` y `product-standard`.

> Regla de oro: **Luis aprueba el maximo UNA vez; Vulcano construye hacia el sin pedir detalle por detalle.** El prompt y el contexto dicen QUE es la app; spec-maxima escribe COMO se ve esa app cuando esta terminada al 100% — y eso se vuelve el contrato.

El problema que resuelve: Luis no quiere darnos las cosas pieza por pieza. Antes, cada app se construia preguntando "y esto como?", "y aqui que va?". spec-maxima toma el giro + lo que ya existe y **deduce y escribe el funcionamiento maximo completo** de una sola vez. Luis lo lee, ajusta lo que quiera, lo aprueba, y a partir de ahi es el norte: todo lo que se construye se mide contra esta spec.

---

## Conexion al Brain

```
Relay exec (bash):  POST http://178.105.135.26/brain/exec   body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):  POST http://178.105.135.26/brain/query  body {"secret":"superclaude2025","query":"..."}
```

**REGLAS DURAS:**
- Una sentencia SQL por query. No separar con `;`.
- Relay re-entrante single-process: NUNCA correr scripts EN Hetzner que llamen al relay. Los `curl` los dispara el agente.
- Las skills viven en `/root/.claude/skills/<nombre>/SKILL.md`; el watcher las sincroniza al marketplace `turbillon50/vulcano-marketplace`.

---

## ENTRADA

1. El `{contexto}` que dejo `context-min` (giro, roles, modulos, stack):
```
SELECT id,name,domain,stack,phase,next_step FROM projects WHERE id='<id>'
```
2. El **informe de inteligencia** de `system-intel` (estandar comercial + extras + backlog):
```
SELECT commercial_standard,extras,backlog FROM intel_reports WHERE project_id='<id>' ORDER BY created_at DESC LIMIT 1
```
3. **Lo que YA existe** — si la app tiene repo/manual/produccion, leerlo SIEMPRE antes de escribir la spec (no inventar sobre lo construido):
```
# repos tipicos en Hetzner
ls /root/<id> ; cat /root/<id>/MANUAL.md /root/<id>/README.md
# rutas reales
find /root/<id> -maxdepth 3 -type d -path "*app*"
```
Si esta en produccion, abrir el dominio con el navegador propio de Hetzner (Playwright) o `web_fetch` para ver el estado real.

## SALIDA

Un documento **"Spec de Funcionamiento Maximo"** (markdown) por proyecto, con la estructura de las 8 secciones de abajo. Se guarda como `/home/folletos/Spec-<id>.md` (URL publica `http://178.105.135.26/folletos/Spec-<id>.md`) y se registra en el Brain (tabla `intel_reports`, campo `spec_maxima`, o `patterns`/`lessons` si no existe). Alimenta a `product-standard`, que construye el esqueleto HACIA esta spec.

---

## PASO 0 — CLASIFICAR: produccion vs demo (CRITICO, va PRIMERO)

Antes de escribir nada, clasificar (regla critica de Luis):

- **PRODUCCION REAL** = tiene **dominio propio + datos/llaves reales**. Trato **premium de funcionalidad, quirurgico**. NUNCA cambios agrestes / reemplazos / reescrituras / datos inventados. Solo **mejoras de funcionalidad con revision de Luis** y deploy a **PREVIEW** antes de produccion. **GUANTES DE SEDA.** Lista actual: mitcan(carnesn.ink), lnred(lnred.ink), rideme(rideme.ink), ruta618(ruta618.life), cierre-yerro(yerro.ink). Cualquiera con dominio + datos reales entra aqui.
- **DEMO** = sin dominio propio o claramente demo. **Manos libres**: limpiar inventados directo, reescribir, sin riesgo. Ej: ohtli, andromeda, aliadas, medix, decaciones, csn-demo.

La clasificacion encabeza la spec en grande. En produccion, la spec NO propone reescrituras: propone el **maximo funcional** al que se llega con mejoras quirurgicas y datos reales (catalogo del cliente) o estado vacio limpio — **nunca inventados**.

---

## METODO EJECUTABLE — las 8 secciones de la Spec

### 1) Encabezado + Clasificacion
- Nombre, dominio, giro en una linea, fecha, autor (Vulcano).
- **PRODUCCION (guantes de seda: solo mejoras funcionales con revision, cero cambios agrestes)** o **DEMO (libre)** — en grande.
- Stack real. Estado actual (fase) en una frase.

### 2) Vision al maximo (que es esta app cuando esta perfecta)
Un parrafo: el job-to-be-done resuelto end-to-end, no la funcion literal. "Cuando esta al maximo, esta app hace ___ para ___, sin fricciones, con ___." Absorbe el `commercial_standard` de system-intel + al menos 1 extra.

### 3) Modulos al maximo (por modulo Y por rol del giro)
El corazon. Por **cada modulo / rol** del giro, una ficha:
- **Que hace al maximo** — la version completa, no el MVP.
- **Flujo completo end-to-end** — paso a paso, desde que entra hasta que termina, incluyendo estados y que ve cada rol.
- **Que datos lleva** — entidades, campos clave, de donde salen (Neon/API real).
- **Official vs placeholder** — que dato/imagen/texto es REAL (catalogo del cliente, llaves vivas) y que es placeholder temporal. En produccion: marcar explicitamente lo real; prohibido inventar.
- **Conexion con otros modulos** — con quien habla (trazabilidad).

### 4) Estandar de calidad (los 5 puntos — Definition of Done)
Aplicar el checklist duro de Luis, instanciado al giro:
1. **ESTABILIDAD**: cero errores de conexion, cero 404, cero crashes; cada click carga y funciona.
2. **MODULOS COMPLETOS**: cada modulo funciona de principio a fin, conectado con los demas (no solo se ve — FUNCIONA).
3. **CONTENIDO COHERENTE**: orden, sin listas duplicadas, sin la misma foto repetida; imagenes variadas y reales por item; organizar por secciones y por sucursales/categorias donde aplique.
4. **MANUAL/README COMPLETO** de toda la app: que hace cada parte, como se registran los usuarios, claves/credenciales, roles, como operar el admin, flujos completos.
5. **DOCUMENTAR + CORREGIR + MEJORAR + IMPLEMENTAR** en ese orden, completo.

### 5) Admin dinamico + White-label (obligatorio en TODAS)
- **Admin dinamico total**: el admin edita textos, imagenes, secciones, precios/catalogo sin tocar codigo; metricas reales de la DB (no hardcode); cambiar estados que se reflejan al usuario.
- **Canvas / mini-programa de diseno (white-label)**: el cliente cambia nombre de la app, **ICONO de escritorio/PWA** (que casi nunca se pone — incluirlo SIEMPRE), logo, colores, look & feel, tipografia, tema dia/noche. Vista previa en vivo. Manifest PWA dinamico.

### 6) Comunicacion usuario <-> admin (vital — leccion Crede-ti)
- Boton flotante "Reportar" en toda la app (sin tapar la bottom-nav — estandar v3).
- Tickets que el admin ve en **tiempo real** + **correo** (Resend), responde, resuelve, lleva notas/seguimiento. Ida y vuelta real, nada de push fragil suelto.

### 7) Extras por giro (incluir SOLO los que apliquen)
Segun el giro, anadir el bloque que corresponda:
- **Recompensas / club / lealtad** (ej. carniceria, retail): puntos, niveles, redenciones, catalogo de premios.
- **Soporte / mesa de ayuda** (todas, pero reforzado en servicios).
- **Pagos / saldo / cashless** (eventos, e-commerce): saldo, cobros atomicos idempotentes, recargas online/offline, webhooks firmados.
- **Geo / mapa / tracking** (movilidad, campo): zonas, matching, tracking en vivo, SOS, rutas.
- **Cumplimiento / fiscal** (yerro, microcreditos): scoring, hallazgos por severidad, plan de accion, expediente/materialidad.
- **Multiempresa / cartera** (despachos, SaaS B2B): panel consolidado, impersonation, reportes PDF por cliente.

### 8) Lo que se considera "TERMINADO AL MAXIMO"
Lista de criterios binarios (cumple/no cumple) que cierran el contrato: "esta app esta al maximo cuando ___". Es lo que `total-supervision` valida en verde antes de liberar. Incluir, ademas, **"Que falta HOY para llegar al maximo"** (gap actual vs spec) para que Luis vea de un vistazo el delta.

---

## COMO SE APRUEBA (el contrato)

1. Vulcano genera la Spec de Funcionamiento Maximo (estas 8 secciones) y la sube a `/home/folletos/Spec-<id>.md` + outputs.
2. **Luis la revisa UNA vez** y ajusta lo que quiera (es el unico momento de "detalle por detalle", y es opcional).
3. Al aprobar, la spec se marca `approved` en el Brain y se vuelve el **norte**: todo build/QA se mide contra ella.
4. En PRODUCCION, cualquier cambio derivado de la spec va a **PREVIEW + revision** antes de produccion (guantes de seda).
5. Vulcano construye HACIA la spec sin volver a preguntar; `product-standard` toma la spec como entrada del esqueleto y `total-supervision` la usa como checklist de "verde".

---

## REGISTRO EN BRAIN (al terminar)

```
-- guardar la spec (intel_reports si existe el campo, si no patterns)
INSERT INTO patterns(key,value) VALUES ('spec-maxima:<id>', '<resumen+url>')
-- leccion
INSERT INTO lessons(title,body) VALUES ('spec-maxima <id>', 'Clasificacion <prod/demo>; URL folleto; gap actual')
-- estado del proyecto
UPDATE projects SET next_step='spec-maxima aprobada -> product-standard' WHERE id='<id>'
```
(Usar las columnas reales de cada tabla; una sentencia por query.)

---

## PIPELINE

```
context-min  ->  system-intel  ->  [ spec-maxima ]  ->  product-standard  ->  design-library  ->  total-supervision
   contexto       inteligencia      CONTRATO maximo       esqueleto             estilo              QA loop verde
```

spec-maxima es la bisagra entre "entender el mercado" (system-intel) y "armar el esqueleto" (product-standard): convierte el entendimiento en un **contrato funcional aprobado** para no construir a ciegas ni preguntando pieza por pieza.

— Forge Labs · Vulcano
