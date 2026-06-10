---
name: context-min
description: Modulo de Contexto Minimo de la FABRICA de productos. Recibe una semilla minima (un logo + lista de features, o pocas palabras) y produce el CONTEXTO COMPLETO del proyecto — giro, roles, modulos, paleta de color (inferida del logo), stack estandar y audiencia — listo para alimentar el resto de la fabrica. ACTIVAR cuando el usuario diga "nuevo proyecto", "arranca un producto", "tengo esta idea", "tengo este logo", "contexto del proyecto", "context-min", "semilla", "que es este negocio", "define el proyecto", o cuando pegue un logo + features sueltas y haya que inferir TODO lo demas. Es el PRIMER modulo del pipeline de fabrica (context-min -> product-standard -> design-library -> total-supervision). Guarda el contexto en el Brain (tabla projects + leccion). Patron probado con Andromeda, Ohtli y Aliadas.
version: 1.0
agents: [Vulcano, Andromeda, Ohtli]
triggers: [nuevo proyecto, arranca un producto, tengo esta idea, tengo este logo, contexto del proyecto, context-min, semilla, define el proyecto, que es este negocio]
---

# context-min — Modulo de Contexto Minimo

Primer eslabon de la FABRICA. Convierte una **semilla minima** en un **contexto de proyecto estructurado** que el resto de los modulos consumen sin volver a preguntar nada.

> Regla de oro: **de poco, sale todo.** El cliente nunca trae el brief completo. Trae un logo y 4 features. El modulo infiere lo demas y lo deja escrito en el Brain.

---

## Conexion al Brain

```
Relay exec (bash):  POST http://178.105.135.26/brain/exec   body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):  POST http://178.105.135.26/brain/query  body {"secret":"superclaude2025","query":"..."}
```

**REGLAS DURAS:**
- Una sentencia SQL por query. No separar con `;`.
- El relay es **re-entrante single-process**: NUNCA correr scripts EN Hetzner que llamen al relay. Los `curl` se disparan del lado agente.
- Las skills viven en `/root/.claude/skills/<nombre>/SKILL.md` y el watcher las sincroniza al marketplace `turbillon50/vulcano-marketplace`.

---

## ENTRADA: la semilla minima

Cualquiera de estas basta:
- **Logo** (imagen/SVG/colores) + **lista de features** sueltas.
- **Pocas palabras**: "una app para vender experiencias", "tienda de iPhones", "memorias para el mas alla".
- Un nombre + un giro.

Si solo hay logo: se infiere paleta de los colores dominantes. Si solo hay palabras: se infiere giro y se propone paleta segun el rubro (ver design-library para el catalogo de vibes).

---

## SALIDA: el "contexto de proyecto" estructurado

Siempre se produce este objeto. Es el contrato que `product-standard` consume.

```json
{
  "id": "andromeda",
  "name": "Andromeda",
  "giro": "marketplace de servicios creativos",
  "audiencia": "freelancers y pymes LATAM, 25-45, movil-first",
  "roles": ["publico", "usuario", "admin"],
  "modulos": ["catalogo", "perfil", "panel-admin", "mensajeria usuario<->admin", "pagos"],
  "color": {"primario": "#6D28D9", "fondo": "#0B0B12", "acento": "#22D3EE", "inferido_de": "logo"},
  "vibe_sugerido": "obsidian/dark premium",
  "stack": {
    "frontend": "Next.js + Tailwind",
    "auth": "Clerk (magic-link)",
    "db": "Neon Postgres",
    "pagos": "Stripe / Mercado Pago",
    "infra": "Vercel + dominio",
    "comms": "Resend (correo) + Twilio (SMS/WhatsApp)",
    "ia": "Gemini",
    "otros_segun_giro": ["Duffel", "Viator", "Reloadly", "ElevenLabs", "Google Maps"]
  },
  "semilla_origen": "logo morado + features: publicar servicio, contratar, chatear, pagar"
}
```

### Como se infiere cada campo
- **giro**: del nombre/features. "vender experiencias" -> marketplace de turismo; "iPhones" -> e-commerce retail; "memorias" -> legado digital.
- **roles**: por defecto SIEMPRE `publico / usuario / admin` (la fabrica no entrega sin panel admin — ver product-standard).
- **modulos**: features del cliente + los OBLIGATORIOS de fabrica (panel-admin, mensajeria usuario<->admin).
- **color**: dominantes del logo. Sin logo, paleta por rubro.
- **vibe_sugerido**: mapea el giro a un vibe del catalogo de `design-library`.
- **stack**: STACK ESTANDAR de fabrica (abajo), recortado/ampliado segun giro.

---

## STACK ESTANDAR de la fabrica

| Capa | Default | Cuando cambia |
|---|---|---|
| Frontend | Next.js + Tailwind | siempre |
| Auth | Clerk (magic-link, entrada libre en demos) | siempre |
| DB | Neon Postgres | siempre |
| Pagos | Stripe + Mercado Pago | si hay cobro |
| Infra | Vercel + dominio | siempre |
| Correo | Resend | siempre (admin recibe correo — leccion Crede-ti) |
| SMS/WhatsApp | Twilio | notificaciones/verificacion |
| IA | Gemini | si hay generacion/chat |
| Viajes | Duffel / Viator | giro turismo |
| Recargas | Reloadly | giro telco/recargas |
| Voz | ElevenLabs | giro audio/legado |
| Mapas | Google Maps | giro local/logistica |

---

## PROCEDIMIENTO

1. **Recibir semilla.** Logo + features o pocas palabras.
2. **Inferir** giro, audiencia, roles, modulos, color, vibe, stack (tablas de arriba).
3. **Escribir el contexto** en el Brain (tabla `projects`), una sentencia por query:
   ```
   INSERT INTO projects (id,name,domain,stack,phase,active,last_agent,last_action,next_step)
   VALUES ('andromeda','Andromeda',NULL,'{"frontend":"Next.js"}'::jsonb,'contexto',true,'context-min','contexto inferido de semilla','product-standard')
   ON CONFLICT (id) DO UPDATE SET stack=EXCLUDED.stack, phase='contexto', next_step='product-standard', updated_at=now()
   ```
4. **Registrar leccion** del patron:
   ```
   INSERT INTO lessons (project_id,type,area,lesson,fix,source)
   VALUES ('andromeda','win','contexto','semilla minima basta para inferir contexto completo','plantilla context-min','context-min')
   ```
5. **Handoff** -> entregar el objeto contexto a `product-standard`.

---

## HANDOFF / PIPELINE

```
[SEMILLA] -> context-min -> {contexto} -> product-standard -> design-library -> total-supervision -> [PRODUCTO SUPERVISADO]
```

- **Produce** el `contexto` (JSON) y lo deja en `projects` del Brain.
- **El siguiente modulo** `product-standard` LEE este contexto (`SELECT * FROM projects WHERE id='...'`) y le inyecta el esqueleto obligatorio.
- Si falta el logo, se pide UNA vez; si no llega, se infiere paleta por rubro y se sigue (ejecucion-primero).

## Patron probado
Andromeda, Ohtli y Aliadas salieron asi: una semilla minima -> contexto completo en una corrida, sin brief largo. Registrado como `win` en `lessons`.
