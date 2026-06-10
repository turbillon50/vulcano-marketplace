---
name: system-intel
description: Comprension de Sistema + Analisis de Competencia de la FABRICA. Evita que un producto salga COJO por construir solo "la funcion literal del prompt". Toma el contexto de context-min, entiende a fondo el DOMINIO y el problema de negocio, investiga competidores reales del giro (features, precios, diferenciadores), define el ESTANDAR COMERCIAL (table stakes + lo que el usuario espera), propone EXTRAS de valor (dar de mas) y deja un BACKLOG por fases (ahora/despues/vision). Produce un "informe de inteligencia" por proyecto que se guarda en el Brain y ALIMENTA a product-standard. Se apoya en tech-research, WebSearch, web_fetch, el navegador de Hetzner y vibe-prospecting. ACTIVAR cuando el usuario diga "analisis de competencia", "que hace la competencia", "estandar comercial", "comprension del sistema", "que le falta", "como lo hacen otros", "benchmarking", "diferenciador", "que no salga cojo", "system-intel", o despues de context-min y ANTES de product-standard. SEGUNDO eslabon del pipeline (context-min -> system-intel -> product-standard -> design-library -> total-supervision).
version: 1.0
agents: [Vulcano]
triggers: [analisis de competencia, que hace la competencia, estandar comercial, comprension del sistema, que le falta, como lo hacen otros, benchmarking, diferenciador, que no salga cojo, system-intel]
---

# system-intel — Comprension de Sistema + Analisis de Competencia

Segundo eslabon de la FABRICA. Se mete ENTRE `context-min` y `product-standard`.

> Regla de oro: **construimos productos COMPETITIVOS, no solo funcionales.** El prompt del cliente describe la funcion literal; system-intel descubre lo que el mercado YA da por hecho y lo que nos pone arriba. Si solo hacemos lo que pidio el prompt, sale cojo.

El problema que resuelve: cuando armamos una app por contexto, nos LIMITAMOS a la funcion literal. Una "app de limpieza" termina siendo un formulario de agendar — y la competencia ya trae recurrencia, seguro, rating, pago integrado y tracking. system-intel cierra esa brecha ANTES de que product-standard arme el esqueleto.

---

## Conexion al Brain

```
Relay exec (bash):  POST http://178.105.135.26/brain/exec   body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):  POST http://178.105.135.26/brain/query  body {"secret":"superclaude2025","query":"..."}
```

**REGLAS DURAS:**
- Una sentencia SQL por query. No separar con `;`.
- Relay re-entrante: scripts EN Hetzner NO llaman al relay; los `curl` los dispara el agente.

---

## ENTRADA
El `{contexto}` que dejo `context-min` en `projects`:
```
SELECT id,name,domain,stack,phase,next_step FROM projects WHERE id='aliadas'
```
De ahi salen: giro, audiencia, modulos inferidos, localidad. Eso es la semilla del analisis.

## SALIDA
Un **informe de inteligencia** estructurado (6 bloques de abajo) que se guarda en `intel_reports` del Brain y se entrega a `product-standard` para que el esqueleto incluya lo competitivo, no solo lo basico.

---

## METODO EJECUTABLE (6 pasos)

### 1) Comprension de sistema
A partir del `{contexto}`, entender el DOMINIO y el problema de negocio COMPLETO, no la tarea literal.
- ¿Quien paga y por que? ¿Quien ejecuta? ¿Cual es el momento de dolor real?
- ¿Que job-to-be-done resuelve? (no "agendar limpieza" sino "tener mi casa limpia sin gestionarlo yo, con confianza en quien entra").
- Mapear actores, flujo de valor y donde esta la friccion.
- Salida parcial: `domain_understanding` (parrafo + JTBD + actores).

### 2) Analisis de competencia
Investigar quienes son los competidores/referentes del giro y como lo resuelven.
- Herramientas: **tech-research** (si existe), **WebSearch**, **web_fetch**, el **navegador de Hetzner**, y **vibe-prospecting** para datos de empresas (tamano, stack, eventos).
- Para cada competidor sacar: features clave, modelo (marketplace vs agencia/operado), precio/comision, diferenciador, debilidad.
- Construir **matriz competidores × features** (tabla). Marca ✓/✗/parcial por feature.
- Salida parcial: `competitors` (JSON: lista + matriz).

### 3) Busqueda de soluciones / mejores practicas
¿Que patrones YA existen para este problema? No reinventar.
- Patrones de producto del giro (recurrencia, rating bidireccional, pago en escrow, geo-match, reposicion de proveedor, etc.).
- Consultar `patterns` del Brain por si ya horneamos algo del mismo giro.
- Salida parcial: `best_practices` (lista de patrones reutilizables + de donde).

### 4) Estandar comercial
Definir que DEBE tener el producto para competir de verdad: **table stakes** (lo minimo que el mercado ya da por hecho) + lo que el usuario espera.
- Si no lo trae, sale cojo respecto a la competencia.
- Salida parcial: `commercial_standard` (checklist de "no sale sin esto a nivel mercado").

### 5) Dar de MAS
Extras de valor que SUPEREN lo pedido: diferenciadores que nos pongan arriba.
- Sacados de los gaps de la matriz (lo que NADIE del giro hace bien) + ventaja de nuestro stack (Twilio/Resend/Stripe/IA).
- Salida parcial: `extras` (3–6 diferenciadores con racional).

### 6) Backlog futuro (roadmap por fases)
Documentar las soluciones posteriores para no perder ideas.
- **Ahora** (MVP competitivo) / **Despues** (V1) / **Vision** (V2+).
- Salida parcial: `backlog` (JSON por fase).

---

## PERSISTENCIA — tabla `intel_reports`

El informe se guarda completo (una corrida = un row, upsert por proyecto):

```
CREATE TABLE IF NOT EXISTS intel_reports (
  id serial PRIMARY KEY,
  project_id text NOT NULL,
  domain_understanding text,
  competitors jsonb,
  best_practices jsonb,
  commercial_standard jsonb,
  extras jsonb,
  backlog jsonb,
  source text DEFAULT 'system-intel',
  created_at timestamptz DEFAULT now()
)
```

Escritura (una sentencia por query; usa $$...$$ para el JSON):
```
INSERT INTO intel_reports (project_id,domain_understanding,competitors,best_practices,commercial_standard,extras,backlog)
VALUES ('aliadas', $$...$$, $$[...]$$::jsonb, $$[...]$$::jsonb, $$[...]$$::jsonb, $$[...]$$::jsonb, $${...}$$::jsonb)
```

product-standard LEE asi:
```
SELECT commercial_standard,extras,backlog FROM intel_reports WHERE project_id='aliadas' ORDER BY created_at DESC LIMIT 1
```

---

## HANDOFF / PIPELINE

```
context-min -> [system-intel: + informe de inteligencia] -> product-standard -> design-library -> total-supervision
```

- **Consume** el `{contexto}` de `context-min` (`SELECT ... FROM projects`).
- **Produce** el informe en `intel_reports` y actualiza el Brain:
  ```
  UPDATE projects SET phase='intel', next_step='product-standard', last_agent='system-intel', updated_at=now() WHERE id='aliadas'
  ```
- **Entrega** a `product-standard`: el `commercial_standard` se vuelve parte del checklist "no sale sin esto", los `extras` entran al esqueleto, y el `backlog` queda registrado para fases futuras.
- **Contrato con product-standard:** el esqueleto A/B/C de product-standard DEBE absorber el `commercial_standard` + al menos 1 `extra`. Si el esqueleto ignora el informe, el producto sale cojo.

---

## REGLA DE EXPRIMIR (Codex/Grok/IA externa)

Para la fase 2–3 (competencia y patrones) exprime los modelos externos: pide a Codex/Grok un barrido de competidores y features del giro, contrasta con WebSearch y depura. No te quedes con un solo tiro.

---

## EJEMPLO DE INFORME (corrida de prueba: "app de limpieza tipo Aliadas")

**1. Comprension de sistema**
JTBD: "Tener mi casa/oficina limpia sin gestionarlo yo, con CONFIANZA en quien entra a mi espacio." Quien paga: hogares/oficinas urbanas ocupadas. Quien ejecuta: aliadas (trabajadoras). Dolor real: no es "agendar" — es confianza + consistencia (misma persona, calidad pareja) + cero fricción de pago/reagenda. La app NO es un formulario: es un marketplace operado con capa de confianza.

**2. Matriz competidores × features**

| Feature | Aliada (MX) | Zolvers (MX) | Homely (MX) | Handy (US) | TaskRabbit (US) |
|---|---|---|---|---|---|
| Agendar 1 vez | ✓ | ✓ | ✓ | ✓ | ✓ |
| Recurrencia (semanal/quincenal) | ✓ | ✓ | parcial | ✓ | ✓ |
| Mismo proveedor recurrente | ✓ | parcial | ✓ | parcial | ✓ |
| Rating bidireccional | ✓ | ✓ | ✓ | ✓ | ✓ |
| Pago in-app | ✓ | ✓ | parcial | ✓ | ✓ |
| Reposición si falla la aliada | ✓ (agencia) | ✗ | ✓ | ✓ | ✗ |
| Protocolo/estándar de calidad | ✓ | ✗ | ✓ | parcial | ✗ |
| Tracking/ETA del servicio | parcial | ✗ | ✗ | parcial | ✓ |
| Formalidad laboral / seguro | parcial | ✗ | ✓ | ✗ | ✗ |

Modelos: Aliada/Homely = **agencia operada** (estándar, reposición, supervisión). Zolvers/TaskRabbit = **marketplace** (eliges por perfil/reviews). Comisiones de referencia del giro: ~15–40% (Zolvers ~40% contacto inicial; Handy ~25%; TaskRabbit ~15% fee). Precio US 2026: clean estándar $150–250, deep $250–400; TaskRabbit ~$33/h.

**3. Mejores prácticas / patrones reutilizables**
Recurrencia con auto-agenda de N citas + recordatorio 72h (TaskRabbit); descuento por recurrencia (Tidy/MaidsApp); geo-match + sticky-provider (misma aliada); escrow de pago (cobra al confirmar servicio); reposición automática de proveedor; protocolo de calidad verificable.

**4. Estándar comercial (table stakes — no sale sin esto)**
Agendar 1 vez + recurrente; mismo proveedor recurrente; rating bidireccional; pago in-app (Stripe); reposición si la aliada cancela; protocolo/checklist de calidad por servicio; recordatorios automáticos; perfiles verificados con reviews.

**5. Dar de MÁS (diferenciadores)**
- **Confianza verificable**: verificación de identidad de la aliada (Twilio Verify) + check-in/out con foto del antes/después.
- **Tracking en vivo + ETA** (la mayoría del giro MX no lo tiene bien).
- **Canal directo cliente↔aliada↔admin** con respaldo por correo (Resend) — la lección Crede-ti aplicada al giro.
- **Reagenda 1-tap y reposición proactiva** (si la aliada falla, el sistema ofrece sustituta antes de que el cliente reclame).
- **Bono de fidelidad / membresía** con descuento por recurrencia.
- **Modo oficina/empresa** (facturación + multi-sede) — segmento que los marketplaces atienden flojo.

**6. Backlog futuro**
- **Ahora (MVP competitivo):** agendar 1-vez+recurrente, mismo proveedor, pago Stripe, rating bidireccional, reposición básica, recordatorios, canal+correo admin, verificación de identidad.
- **Después (V1):** tracking/ETA en vivo, check-in/out con foto, membresía/fidelidad, descuento por recurrencia, panel de calidad con checklist.
- **Visión (V2+):** modo empresa/multi-sede + facturación, matching inteligente por afinidad/zona, seguro/formalidad laboral como sello, marketplace abierto de aliadas con onboarding propio.

---

## CHECKLIST "system-intel no entrega sin esto"
- [ ] `domain_understanding` con JTBD real (no la tarea literal).
- [ ] Matriz competidores × features con ≥3 competidores reales del giro.
- [ ] Precios/comisiones de referencia del mercado.
- [ ] `commercial_standard` (table stakes) explícito.
- [ ] ≥3 `extras` que superen lo pedido.
- [ ] `backlog` por fases ahora/después/visión.
- [ ] Informe guardado en `intel_reports` + `projects` actualizado a next_step='product-standard'.
