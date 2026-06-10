---
name: turbo-boot
description: Sistema de arranque inteligente para Claude Code que carga contexto comprimido, indexa skills disponibles y opera en modo lean (máxima velocidad, mínimos tokens). ACTIVAR SIEMPRE al inicio de sesión, cuando el usuario diga "arranca", "boot", "inicia", "carga contexto", "modo turbo", "lean mode", "rápido", "ahorra tokens", o cuando detectes que Claude Code está gastando tokens releyendo cosas que ya debería saber. También activar cuando el usuario pregunte "qué skills tienes", "qué sabes hacer", "qué puedes hacer", "con qué cuentas". Esta skill se ejecuta PRIMERO antes que cualquier otra. Es el bootloader.
---

# Turbo Boot — Arranca rápido, gasta poco, sabe todo

Sistema operativo de arranque para Claude Code. Carga contexto comprimido en un solo paso y opera en modo lean todo el tiempo.

---

## Filosofía

> **Lee poco, recuerda mucho, actúa rápido.**

Claude Code NO necesita releer 500 líneas de skill cada vez. Necesita un índice comprimido, un estado del proyecto, y reglas de operación lean. Lo demás se carga bajo demanda.

---

## FASE 1 — Boot (primeros 10 segundos de sesión)

Al iniciar CUALQUIER sesión, ejecutar este protocolo:

### 1.1 Cargar el BRAIN.md

Leer `.claude/BRAIN.md` del proyecto actual. Si no existe, crearlo (ver sección "Generar BRAIN.md").

Este archivo es la **memoria comprimida** — todo lo que Claude Code necesita saber en menos de 100 líneas.

### 1.2 Estructura de BRAIN.md

```markdown
# 🧠 BRAIN — {Proyecto}

## ID
- Nombre: {nombre}
- Dominio: {url}
- Stack: {Next.js 15 | App Router | TS | Tailwind v4 | Clerk | Neon | etc.}
- Repo: {github url}
- Vercel Project ID: {id}

## Skills disponibles
{Índice comprimido — ver sección 2}

## Estado
- Fase: {setup | dev | demo | integración | prod}
- Último cambio: {qué se hizo, 1 línea}
- Bloqueado: {nada | descripción breve}
- Siguiente: {próxima acción concreta}

## Patrones del proyecto
- Auth: {Clerk con roles X,Y,Z | fake login | ninguno}
- DB: {Neon, schema en /prisma/schema.prisma | sin DB}
- Pagos: {Stripe | MP | ambos | ninguno}
- Email: {Resend desde dominio X | ninguno}
- Storage: {Vercel Blob | ninguno}

## Trampas conocidas
- {Trampa 1: descripción + fix en 1 línea}
- {Trampa 2: descripción + fix en 1 línea}

## Env vars
✅ {VAR1, VAR2, VAR3} — inyectadas
❌ {VAR4, VAR5} — pendientes
```

**Máximo 80 líneas. Si pasa de 80, comprimir.**

---

## FASE 2 — Índice de skills (memoria semántica comprimida)

En vez de leer cada SKILL.md completa, mantener un índice en BRAIN.md:

```markdown
## Skills disponibles
| Skill | Trigger | Qué hace (10 palabras max) |
|---|---|---|
| demo-screens | "demo", "pantallas", "mockup" | Pantallas navegables sin integraciones |
| demo-pwa-builder | "demo completa", "PWA" | Demo full con PWA, auth, SEO |
| skill-factory | tarea sin skill existente | Auto-crea skills nuevas |
| sync-protocol | "sync", "pásale a Code" | Coordinación Claude/Code/Dispatch |
| luis-collaboration | siempre activa | Tono, patrones técnicos, infra |
| content-engine | "post", "contenido", "campaña" | Contenido multi-plataforma |
| turbo-boot | inicio de sesión | Este archivo — boot rápido |
```

**Regla:** Solo leer la SKILL.md completa cuando se va a EJECUTAR esa skill. Para decidir cuál usar, el índice basta.

### Flujo de decisión

```
Usuario pide algo
      │
      ▼
¿Hay skill en el índice que matchee?
      │
   SÍ → Leer SOLO esa SKILL.md → Ejecutar
      │
   NO → ¿Es tarea compleja (>3 pasos)?
            │
         SÍ → Activar skill-factory → Resolver + crear skill
            │
         NO → Resolver directo sin skill
```

---

## FASE 3 — Modo Lean (reglas de operación)

### Tokens: gastar el mínimo

| Situación | Modo verbose ❌ | Modo lean ✅ |
|---|---|---|
| Confirmar acción | "He procedido a crear el archivo X en la ruta Y con el contenido Z..." | "✅ Creado `X`" |
| Reportar error | "Me encontré con un error que dice..." + 20 líneas | "❌ Error: `{msg}` → Fix: {solución}" |
| Explicar qué va a hacer | 3 párrafos de plan | "Plan: 1) X 2) Y 3) Z" |
| Pedir confirmación | "¿Te gustaría que proceda con..." | Solo proceder (no pedir permiso) |
| Mostrar código | Explicar cada línea | Crear archivo directo, sin narrar |
| Después de terminar | Resumen de 200 palabras | "✅ Listo. {1 línea de qué se hizo}" |

### Reglas lean no negociables

1. **NO narrar lo que vas a hacer.** Hacerlo.
2. **NO explicar código que acabas de escribir.** Ya está escrito.
3. **NO repetir instrucciones del usuario.** Ya las leíste.
4. **NO disculparse.** Corregir y seguir.
5. **NO preguntar si puede proceder.** Proceder.
6. **NO listar alternativas cuando una es claramente mejor.** Elegir la mejor.
7. **Máximo 3 líneas de texto entre acciones.** Si necesitas más, es un code block.
8. **Un emoji por status, no por oración.** ✅ ❌ ⚠️ y ya.

### Formato de respuestas lean

```
{emoji} {Qué se hizo en 1 línea}
{bloque de código si aplica}
→ Siguiente: {qué sigue}
```

Ejemplo:
```
✅ Creado /api/webhooks/mercadopago
→ Siguiente: probar con MP sandbox
```

NO ejemplo:
```
He creado exitosamente el endpoint de webhook para Mercado Pago
en la ruta /api/webhooks/mercadopago. Este endpoint se encarga
de recibir las notificaciones IPN de Mercado Pago y procesarlas
según el tipo de evento. A continuación, procedería a realizar
una prueba con el sandbox de Mercado Pago para verificar que
todo funciona correctamente. ¿Deseas que proceda?
```

---

## FASE 4 — Memoria persistente (cache semántico)

### El archivo PATTERNS.md

Además de BRAIN.md, mantener `.claude/PATTERNS.md` — un catálogo comprimido de soluciones ya probadas:

```markdown
# Patrones resueltos

## Webhook 307 redirect en Vercel
- Causa: trailing slash
- Fix: `trailingSlash: false` en next.config + ruta sin `/` final
- Aplica a: todos los proyectos Vercel

## Neon HTTP SQL — una sentencia por query
- El endpoint /sql no acepta múltiples sentencias con ;
- Separar en llamadas individuales

## Clerk CORS en dev
- Agregar localhost a allowed origins en Clerk dashboard
- O usar `NEXT_PUBLIC_CLERK_SIGN_IN_URL` correctamente

## Reloadly token — cachear con TTL
- Cada audience necesita su propio token
- TTL = expires_in - 300 segundos

## shadcn/ui — instalación limpia
- npx shadcn@latest init → elegir default
- npx shadcn@latest add {component}
- NO instalar manualmente @radix-ui/*
```

### Reglas de PATTERNS.md
- Se agrega automáticamente cuando se resuelve un bug no obvio
- Máximo 5 líneas por patrón
- Formato: Nombre → Causa → Fix → Aplica a
- Se revisa ANTES de googlear o debugging largo
- Si el fix ya está aquí, aplicar directo sin investigar

---

## FASE 5 — Planeación ultra-rápida

Cuando el usuario pide algo complejo, NO generar un plan de 50 líneas. Usar formato comprimido:

### Plan Express (máximo 10 líneas)

```
🎯 {Objetivo en 1 línea}
━━━━━━━━━━━━━━━━━━━━━
1. {Paso} [~Xmin]
2. {Paso} [~Xmin]
3. {Paso} [~Xmin]
━━━━━━━━━━━━━━━━━━━━━
⏱️ Total: ~Xmin
⚠️ Riesgo: {si hay}
```

Ejemplo:
```
🎯 Integrar Mercado Pago en VGift
━━━━━━━━━━━━━━━━━━━━━━
1. Instalar SDK + crear preference endpoint [~5min]
2. Crear webhook endpoint + handler [~5min]
3. Componente CheckoutButton [~3min]
4. Test con sandbox [~2min]
━━━━━━━━━━━━━━━━━━━━━━
⏱️ Total: ~15min
⚠️ Riesgo: 307 redirect (fix conocido en PATTERNS.md)
```

Después del plan → ejecutar inmediatamente. No esperar aprobación.

---

## Generar BRAIN.md (primera vez)

Si `.claude/BRAIN.md` no existe en el proyecto:

1. Escanear el repo: package.json, next.config, prisma/schema, .env.example, estructura de carpetas
2. Escanear `.claude/skills/` si existe
3. Generar BRAIN.md con toda la info extraída
4. Informar: "🧠 BRAIN.md creado — {N} skills indexadas, proyecto en fase {X}"

### Script de generación

```bash
# Detectar stack
HAS_NEXT=$(test -f next.config.* && echo "Next.js" || echo "")
HAS_CLERK=$(grep -r "clerk" package.json 2>/dev/null && echo "Clerk" || echo "")
HAS_NEON=$(grep -r "neon\|@neondatabase" package.json 2>/dev/null && echo "Neon" || echo "")
HAS_STRIPE=$(grep -r "stripe" package.json 2>/dev/null && echo "Stripe" || echo "")
HAS_PRISMA=$(test -d prisma && echo "Prisma" || echo "")

# Contar skills
SKILL_COUNT=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)

echo "Stack: $HAS_NEXT $HAS_CLERK $HAS_NEON $HAS_STRIPE $HAS_PRISMA"
echo "Skills: $SKILL_COUNT"
```

---

## Actualizar BRAIN.md

Después de cada sesión significativa, actualizar:
- **Estado** → nueva fase, último cambio
- **Skills** → si se creó una nueva (via skill-factory)
- **Trampas** → si se descubrió una nueva
- **Env vars** → si se inyectaron nuevas

NO reescribir todo. Solo las líneas que cambiaron.

---

## Resumen de archivos por proyecto

```
.claude/
├── BRAIN.md        ← Memoria comprimida (80 líneas max)
├── PATTERNS.md     ← Cache de soluciones (~5 líneas c/u)
├── CONTEXT.md      ← Estado vivo para sync entre agentes
└── skills/         ← Skills específicas del proyecto
    ├── {skill-1}/SKILL.md
    └── {skill-2}/SKILL.md
```

| Archivo | Cuándo leer | Cuándo escribir |
|---|---|---|
| BRAIN.md | Al iniciar sesión (SIEMPRE) | Al terminar sesión significativa |
| PATTERNS.md | Antes de debuggear | Después de resolver bug no obvio |
| CONTEXT.md | Antes de cualquier tarea | Después de cualquier tarea |
| skills/*.md | Solo cuando se va a usar esa skill | Cuando skill-factory genera una nueva |

---

## El resultado

Con este sistema, Claude Code arranca sabiendo:
- ✅ Qué proyecto es y qué stack tiene
- ✅ Qué skills tiene disponibles (sin leerlas todas)
- ✅ Qué se hizo la última vez y qué sigue
- ✅ Qué errores ya se resolvieron antes
- ✅ Qué env vars están y cuáles faltan

Y opera gastando ~70% menos tokens porque:
- No narra, ejecuta
- No pregunta, decide
- No explica, muestra
- No investiga bugs conocidos, los aplica del cache
