---
name: qa-crew
description: Cuadrilla profesional de QA que prueba cada entrega como probadores humanos ANTES de mandarla a Luis, y motor de AUTO-APRENDIZAJE que registra cada acierto y error en el Brain (tabla lessons + memoria vectorial) para que el sistema se vuelva mas listo con cada corrida. ACTIVAR cuando el usuario diga "QA", "prueba esto", "probar", "testers", "cuadrilla", "antes de entregar", "revisa la app", "calidad", "auditar demo", "esta lista para entregar", "checklist", "responsive", "instalable", "PWA", o cuando se termine cualquier build/demo y antes de mandarlo al cliente. Tambien activar al cerrar cualquier corrida para capturar la leccion aprendida.
version: 1.0
---

# qa-crew — Cuadrilla de QA + Auto-aprendizaje

Dos capacidades en una skill:

- **(A) Cuadrilla de QA**: un swarm de probadores que abre cada entrega como humanos y la rompe antes que el cliente. Nada sale sin checklist verde.
- **(B) Auto-aprendizaje**: cada corrida (acierto o error) se registra solita en el Brain. La fuente de conocimiento se llena sola y se consulta semanticamente.

> Regla de oro: **si algo falla, NO se entrega.** Regresa a refinar con la lista de fallos. Solo el checklist verde libera la entrega.

---

## Conexion al Brain

```
Relay exec (bash):   POST http://178.105.135.26/brain/exec    body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):   POST http://178.105.135.26/brain/query   body {"secret":"superclaude2025","query":"..."}
```

**REGLAS DURAS:**
- Una sentencia SQL por query. No separar con `;`.
- El relay es **single-process re-entrante**: NUNCA correr scripts EN Hetzner que llamen al relay (lo congela). Los `curl` al relay se disparan desde el lado agente, no desde un script dentro de Hetzner.
- Las skills viven en Hetzner en `/root/.claude/skills/<nombre>/SKILL.md`.

---

## PARTE A — Protocolo de QA

### A.1 — QA de Refinamiento (DURANTE el build)
Valida alcance vs spec mientras se construye. Checklist:

- [ ] **3 modos navegables**: publico / usuario / admin, con toggle flotante.
- [ ] **Auth real** (no fake): magic-link con entrada libre en demos.
- [ ] **DB real** (Neon) con **datos demo plausibles** sembrados — no arrays hardcodeados sueltos.
- [ ] **Integraciones del catalogo segun objetivo** (Clerk, Neon, Stripe, MercadoPago, WhatsApp, Twilio, Resend, Gemini, Google Maps, Duffel, Viator, Reloadly, ElevenLabs) — solo las que el giro del negocio requiera.
- [ ] **Cero pantallas vacias**: cada vista tiene contenido o estado vacio disenado.
- [ ] **Imagenes Higgsfield** (hero y graficos), NUNCA lucide ni placeholders.
- [ ] **Accent propio del proyecto** (no imponer azul VMomentum; cada app su color).

Si falta algo, se anota y se sigue refinando. No se pasa a Entrega.

### A.2 — QA de Entrega (ANTES de mandar a Luis) — el SWARM
Cada tester abre la app en **3 viewports** y corre el barrido completo:

| Viewport | Ancho | Que valida |
|----------|-------|------------|
| Movil    | 390px | Barra inferior, tap targets, scroll |
| Tablet   | 768px | Transicion de layout |
| Desktop  | 1440px | Layout ancho real, sidebar |

Cada tester revisa:

1. **Navegacion completa** — todos los links y rutas responden.
2. **Los 3 modos** — publico / usuario / admin entran y funcionan.
3. **Errores de consola** — cero `Uncaught` / cero 404 en consola.
4. **Imagenes y links rotos** — cero `img` rota, cero href muerto.
5. **Responsive REAL** — en desktop NO se ve como tira de celular centrada. Debe usar todo el viewport con layout ancho / sidebar. **BANDERA ROJA si hay `max-w-md` global.**
6. **Lighthouse PWA score** — instalable de verdad: **manifest + service worker + HTTPS**. Si no es instalable, no pasa.

**Como correr el barrido (lado agente, no en Hetzner):**
- Navegacion/consola/responsive: Chrome MCP (`navigate`, `read_console_messages`, `resize_window` a 390/768/1440, `get_page_text`).
- Links/imagenes rotas: revisar requests de red (status >=400).
- PWA: verificar `/manifest.webmanifest` (o `manifest.json`), registro de `serviceWorker`, y HTTPS. Lighthouse via `npx lighthouse <url> --only-categories=pwa` desde el sandbox del agente, o checklist manual de los 3 requisitos.

### A.3 — Salida: reporte "checklist verde"
Genera un reporte con cada item marcado. Formato:

```
QA REPORT — <proyecto> — <url> — <fecha>
REFINAMIENTO: [ok/x por item]
ENTREGA (390/768/1440): [ok/x por item y viewport]
PWA: manifest [ok] sw [ok] https [ok] score [n]
VEREDICTO: VERDE (entregar)  |  ROJO (regresar a refinar: <lista de fallos>)
```

- **VERDE** -> se entrega.
- **ROJO** -> NO se entrega. Vuelve a A.1 con la lista de fallos. Cada fallo se registra como leccion (Parte B).

### A.4 — Estandar PWA v3 (responsive)
- Breakpoints reales (sm/md/lg/xl), no un solo ancho.
- Contenedores fluidos: `max-w-7xl mx-auto` en desktop (NUNCA `max-w-md` global).
- Navegacion: barra inferior en movil -> **sidebar en `lg:`**.
- Probar SIEMPRE en los 3 anchos antes de dar verde.
- Instalable: manifest con `name`, `icons` (192+512), `start_url`, `display: standalone` + service worker registrado + servido por HTTPS.

---

## PARTE B — Auto-aprendizaje (loop de conocimiento)

### B.1 — La tabla `lessons` (Neon)
```sql
CREATE TABLE IF NOT EXISTS lessons (
  id SERIAL PRIMARY KEY,
  ts TIMESTAMPTZ DEFAULT NOW(),
  project_id TEXT,
  type TEXT NOT NULL CHECK (type IN ('acierto','error')),
  area TEXT,
  lesson TEXT NOT NULL,
  fix TEXT,
  source TEXT DEFAULT 'qa-crew'
);
```
Ya creada en el Brain. `area` ejemplos: build, ui, deploy, infra, branding, auth, demo, responsive, email, imagenes, pwa.

### B.2 — LA REGLA (se dispara solita)
Tras **cada corrida QA** (o cualquier build), si hubo **acierto reproducible** o **error**, se inserta una fila en `lessons` automaticamente, sin pedir confirmacion. INSERT via relay (lado agente):

```
POST /brain/query  query: INSERT INTO lessons (project_id,type,area,lesson,fix,source) VALUES ('<proj>','error','responsive','<que paso>','<como se arreglo>','qa-crew')
```

Y se appendea una linea legible al log de lecciones en Hetzner via /brain/exec:

```
echo "$(date -u +%FT%TZ) | LESSON <error|acierto> | <area> | <proj> | <leccion> -> <fix>" >> /root/brain/vulcano-lessons.md
```

Disparadores tipicos: veredicto ROJO (cada fallo = error), veredicto VERDE estable (patron que funciono = acierto), cualquier tropiezo del entorno (postcss, vercel BLOCKED, relay congelado, resend dominio no verificado).

### B.3 — Memoria vectorial (semantico)
El Brain ya tiene `pgvector` y tabla `embeddings (id, content, metadata jsonb, embedding vector, created_at)` con Gemini `gemini-embedding-001` (1024 dims). Para que las lecciones sean consultables semanticamente ("que aprendimos de X"), se **espeja** cada leccion en `embeddings`:

1. Generar embedding del texto `"<area>: <lesson> -> <fix>"` con Gemini `gemini-embedding-001` (1024 dims). (La llamada a Gemini va al API de Google, NO al relay — no viola la regla re-entrante.)
2. Insertar:
```sql
INSERT INTO embeddings (content, metadata, embedding)
VALUES ('<area>: <lesson> -> <fix>', '{"source":"lessons","lesson_id":<id>,"project_id":"<proj>","type":"<tipo>"}', '[...1024 floats...]')
```
3. Consultar por similitud:
```sql
SELECT content, metadata FROM embeddings
WHERE metadata->>'source' = 'lessons'
ORDER BY embedding <=> '<query_vector>' LIMIT 5
```

Si en alguna corrida no hay Gemini disponible, el hook queda documentado y la fila en `lessons` se inserta igual (lo vectorial se reconcilia despues). El INSERT en `lessons` nunca se bloquea por el embedding.

### B.4 — Consultas utiles
```sql
SELECT type, area, lesson, fix FROM lessons ORDER BY ts DESC LIMIT 20
SELECT count(*) FILTER (WHERE type='error') AS errores, count(*) FILTER (WHERE type='acierto') AS aciertos FROM lessons
SELECT area, count(*) FROM lessons WHERE type='error' GROUP BY area ORDER BY 2 DESC
```

---

## Flujo completo de una corrida
1. Termina el build -> corre **QA Refinamiento** (A.1).
2. Corre **QA Entrega swarm** en 390/768/1440 (A.2).
3. Genera **reporte checklist verde** (A.3).
4. VERDE -> entrega. ROJO -> regresa a refinar + registra cada fallo.
5. **Registra lecciones** (B.2) y **espeja en vectorial** (B.3). Sin pedir permiso.

Ejecucion-primero. Tono mexicano directo. Nada sale en rojo.
