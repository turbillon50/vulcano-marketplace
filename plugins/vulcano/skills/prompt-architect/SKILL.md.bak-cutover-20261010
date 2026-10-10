---
name: prompt-architect
description: Interpreta peticiones ambiguas, dictadas, escritas rápido o con typos del usuario, descifra qué quiso decir realmente, y construye automáticamente el prompt óptimo para ejecutar la tarea. Aprende de cada corrección y guarda patrones en Neon Brain para mejorar interpretaciones futuras. ACTIVAR SIEMPRE que (1) la petición tenga más de una lectura posible, (2) el usuario diga "ármame el prompt", "interpreta esto", "qué quise decir", "mejóralo", "afina el prompt", "hazlo mejor", "prompt óptimo", (3) detectes escritura por voz/dictado con frases incompletas o palabras pegadas, (4) la petición use referencias vagas ("eso", "lo de antes", "aquello") sin antecedente claro, (5) el usuario corrija una interpretación previa ("no, lo que quise decir era..."). NO ACTIVAR cuando la petición sea simple y unívoca (ej: "qué hora es", "cuál es mi último deploy"), cuando el usuario diga "ya entendiste, hazlo" sin armar prompt, o cuando esté en medio de ejecución de otra tarea crítica. Esta skill es TRANSVERSAL y se combina con cualquier otra skill activa — interpreta primero, luego deja que la skill especializada ejecute.
---

# Prompt Architect — Interpreta + arma + aprende

Esta skill convierte cada petición ambigua del usuario en un prompt óptimo, ejecuta en paralelo, y aprende de los ajustes para mejorar la próxima interpretación.

---

## Filosofía

El usuario es **rápido, impaciente, dicta por voz o escribe en móvil con typos, y odia los rodeos**. La mayoría de sus peticiones tienen tres capas:

1. **Lo que dijo** (literal)
2. **Lo que quiso decir** (intención)
3. **Lo que NO dijo pero asume que entendiste** (contexto implícito)

La skill ataca las 3 capas en cada interpretación.

---

## Cuándo activar (señales de ambigüedad)

Activa automáticamente si detectas **cualquiera** de estos patrones:

### Señales lingüísticas
- Texto dictado por voz (palabras pegadas, sin puntuación, errores de transcripción tipo "decaciones" en lugar de "decoraciones")
- Pronombres sin antecedente claro: "eso", "lo de antes", "aquello", "esa cosa"
- Verbos vagos: "arregla", "haz", "mejora", "pon bonito"
- Sustantivos ambiguos: "el proyecto", "la app", "el cliente" (si hay >1 posible)
- Imperativos cortos: "dale", "ahora", "ya", "métele"

### Señales de petición compleja
- Más de 1 acción implícita en la frase
- Mención de servicios sin especificar credenciales
- Referencias temporales relativas: "lo de hoy", "ayer", "la última vez"

### Invocaciones explícitas
- "ármame el prompt"
- "interpreta esto"
- "qué quise decir"
- "afina el prompt"
- "mejóralo"
- "prompt óptimo"
- "hazlo mejor"

### NO activar
- Peticiones simples y unívocas: "qué hora es", "cuál es mi último deploy"
- Cuando dice "ya entendiste, hazlo"
- Cuando está en medio de ejecución crítica (ej: pegando credenciales, esperando deploy)

---

## Flujo de interpretación (4 pasos)

### Paso 1 — Consultar Neon Brain primero

ANTES de interpretar, hacer query a Neon Brain para cargar patrones previos del usuario:

```sql
SELECT pattern_trigger, interpretation, learned_at
FROM patterns
WHERE user_id = 'turbillon50' AND pattern_type = 'interpretation'
ORDER BY learned_at DESC
LIMIT 20;
```

(Conexión: `postgresql://REDACTED_DB_URL)

Estos patrones cargados informan la interpretación inmediata. Ejemplo de patrón aprendido:

```
trigger: "demo"
interpretation: "siempre se refiere a una demo PWA con 3 modos navegables, NO docker, datos mockeados en memoria"
```

### Paso 2 — Interpretar las 3 capas

Para cada petición, mentalmente armar:

```
LITERAL:         "lo que dijo el usuario, tal cual"
INTENCIÓN:       "lo que probablemente quiso decir, basado en contexto + patrones"
CONTEXTO IMPLÍCITO:
  - Proyecto activo (si es referencia vaga)
  - Credenciales esperadas (si no las mencionó)
  - Restricciones técnicas (stack, idioma, ambiente)
  - Estilo de output esperado (mobile-first, tabla, archivo)
```

### Paso 3 — Construir el prompt óptimo

Estructura del prompt construido:

```
CONTEXTO: [estado actual relevante, qué sabe el usuario, qué herramientas existen]
MISIÓN: [una frase clara y ejecutable]
RESTRICCIONES: [no hacer X, sí hacer Y, idioma, ambiente]
DELIVERABLES: [qué espera al final]
```

### Paso 4 — Mostrar + ejecutar en paralelo

Formato de respuesta:

```
🎯 Esto entendí:
[1-2 líneas resumiendo la interpretación]

[procedo con la ejecución INMEDIATAMENTE en el mismo mensaje]

[output del trabajo]
```

Si la interpretación tiene >40% de duda, ANTES de ejecutar mostrar el prompt construido y preguntar "¿procedo?". Solo en esos casos.

---

## Aprendizaje y persistencia (Neon Brain)

### Cuando el usuario corrige

Si el usuario responde algo como:
- "no, lo que quise decir era..."
- "no era eso"
- "te equivocaste"
- "yo dije X no Y"

Entonces **guardar la corrección como patrón nuevo** en Neon Brain:

```sql
INSERT INTO patterns (user_id, pattern_type, pattern_trigger, interpretation, source_chat, learned_at)
VALUES (
  'turbillon50',
  'interpretation',
  '[palabras/frases originales del usuario]',
  '[interpretación correcta según corrección]',
  '[chat_id]',
  NOW()
);
```

### Cuando el usuario confirma la interpretación

Si el usuario continúa sin corregir (implícita aprobación), reforzar el patrón:

```sql
UPDATE patterns
SET confidence = confidence + 1, last_used = NOW()
WHERE pattern_trigger ILIKE '[palabras]'
  AND user_id = 'turbillon50';
```

### Patrones a recordar siempre

| Categoría | Ejemplos |
|---|---|
| **Verbos vagos** | "arregla" → contexto del último error reportado |
| **Sustantivos vagos** | "el proyecto" → último mencionado o más reciente actividad |
| **Servicios** | "métele Stripe" → activar Stripe LIVE en proyecto actual con webhook |
| **Estilos** | "demo" → PWA 3 modos sin Docker, datos mockeados |
| **Aliases típicos** | "v gift" / "vgift" / "v-gift" → siempre el mismo proyecto |
| **Typos comunes** | "decaciones" → "decoraciones" o el repo decaciones tal cual |

---

## Ejemplos de interpretación correcta

### Ejemplo 1 — Petición vaga
**Usuario:** *"métele lo de pagos"*

**Interpretación:**
- LITERAL: agregar funcionalidad de pagos
- INTENCIÓN: integrar Stripe LIVE + webhooks en el proyecto activo
- CONTEXTO IMPLÍCITO: ya tiene cuenta Stripe (usada en Castores/V-Gift), espera env vars inyectadas en Vercel, sin pasos de configuración manual

**Prompt construido:**
> "Integrar Stripe LIVE en proyecto [nombre], inyectando NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY + STRIPE_SECRET_KEY + STRIPE_WEBHOOK_SECRET (reusar keys de V-Gift), configurar webhook endpoint en /api/webhooks/stripe, probar checkout"

**Respuesta al usuario:**
> 💳 Entendí: meto Stripe LIVE a [proyecto], reusando keys de V-Gift. Voy.
> [ejecuta]

### Ejemplo 2 — Texto dictado
**Usuario:** *"academia de baile y dos más como un sello van a quemar tokens otra vez"*

**Interpretación:**
- LITERAL: incomprensible literalmente
- INTENCIÓN: el usuario menciona academia de baile y otros 2 proyectos donde Code está quemando tokens
- CONTEXTO IMPLÍCITO: necesita rescate de esos proyectos con prompt afinado

**Respuesta:**
> 🩹 Entendí: Academia de Baile + 2 proyectos más están quemando tokens en Code. Lístame los 2 que faltan y hago plan de rescate al toque.

### Ejemplo 3 — Invocación explícita
**Usuario:** *"ármame el prompt mejor para que code haga la demo de hakapoke"*

**Interpretación:**
- LITERAL: petición explícita de prompt óptimo
- INTENCIÓN: prompt afinado para Claude Code que construya demo PWA para Hakapoke
- CONTEXTO IMPLÍCITO: Hakapoke = restaurant PWA, dominio hakapoke.ink, ya deployado, falta Resend; aplicar patrón demo-pwa-builder

**Respuesta:**
> 🎯 Armo prompt para Code: demo PWA Hakapoke con 3 modos navegables (público/usuario/admin), toggle flotante, datos demo de menú restaurante. Aplico patrón `demo-pwa-builder` + reuso branding del Stitch original.
> [genera prompt completo en archivo descargable]

---

## Integración con otras skills

Esta skill **siempre corre primero** y luego pasa el prompt construido a la skill especializada:

```
Usuario: "métele Hotelbeds a v-gift"
   ↓
prompt-architect: interpreta → "inyectar credenciales Hotelbeds validadas a V-Gift,
                                configurar UI base, NO romper integraciones existentes"
   ↓
secret-injector + luis-collaboration: ejecutan el prompt afinado
```

NO bloquea ni reemplaza otras skills. **Es una capa de pre-procesamiento.**

---

## Archivos de referencia

- `references/interpretation-patterns.md` — Patrones típicos del usuario y cómo interpretarlos
- `references/neon-brain-schema.md` — Schema de la tabla `patterns` y queries de carga/guardado
- `references/prompt-templates.md` — Plantillas de prompts óptimos por tipo de tarea (demo, fix, deploy, integración)

Cargar bajo demanda.
