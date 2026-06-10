---
name: sync-protocol
description: Protocolo de comunicación y sincronización entre Claude (chat/coordinador), Claude Code (ejecutor en terminal local o Hetzner) y Dispatch (agente móvil/control remoto). ACTIVAR SIEMPRE que el usuario mencione coordinación entre agentes, "pásale esto a Claude Code", "dile a Dispatch", "que Code sepa", "actualiza el contexto", "sync", "sincroniza", "estado del proyecto", "qué está haciendo Code", "manda esto a terminal", o cuando se genere un prompt/instrucción que va dirigido a otro agente. También activar cuando el usuario pegue output de Claude Code o Dispatch para que este chat lo interprete. Activar cuando haya handoff de tarea entre agentes. Esta skill es TRANSVERSAL — se usa en combinación con cualquier otra skill cuando hay más de un agente involucrado.
---

# Sync Protocol — Tres agentes, un cerebro

Protocolo para mantener a Claude (chat), Claude Code y Dispatch sincronizados y con contexto compartido.

---

## Arquitectura

```
┌─────────────────────────────────────────────────┐
│                    LUIS                          │
│              (toma decisiones)                   │
└──────┬──────────────┬──────────────┬────────────┘
       │              │              │
       ▼              ▼              ▼
┌────────────┐ ┌────────────┐ ┌────────────┐
│  CLAUDE    │ │ CLAUDE CODE│ │  DISPATCH  │
│  (chat)    │ │ (terminal) │ │  (móvil)   │
│            │ │            │ │            │
│ Planea     │ │ Ejecuta    │ │ Control    │
│ Coordina   │ │ Código     │ │ remoto     │
│ Diagnostica│ │ Deploys    │ │ Comandos   │
│ Skills     │ │ Fixes      │ │ rápidos    │
└────────────┘ └────────────┘ └────────────┘
       │              │              │
       └──────────────┴──────────────┘
                      │
              ┌───────▼───────┐
              │  CONTEXT.md   │
              │ (estado real) │
              └───────────────┘
```

---

## El archivo CONTEXT.md (fuente de verdad)

Cada proyecto debe tener un archivo `.claude/CONTEXT.md` en la raíz del repo. Este archivo es el estado compartido que TODOS los agentes leen antes de actuar.

### Estructura

```markdown
# {Nombre del Proyecto} — Context

## Estado actual
- **Fase:** {setup | desarrollo | demo | integración | producción}
- **Último agente:** {claude-chat | claude-code | dispatch}
- **Última acción:** {descripción breve}
- **Timestamp:** {YYYY-MM-DD HH:MM}

## En progreso
- [ ] {Tarea activa 1} → asignado a: {agente}
- [ ] {Tarea activa 2} → asignado a: {agente}

## Completado hoy
- [x] {Tarea completada}

## Bloqueado
- ⚠️ {Qué está bloqueado y por qué}

## Próximo paso
{La siguiente acción concreta que debe ejecutarse}

## Env vars pendientes
| Variable | Servicio | Status |
|---|---|---|
| {VAR} | {servicio} | ✅ / ❌ / ⏳ |

## Notas entre agentes
- **Claude → Code:** {instrucción pendiente}
- **Code → Claude:** {resultado o duda}
- **Dispatch → Code:** {comando enviado}
```

### Reglas del CONTEXT.md
- Claude Code lo ACTUALIZA después de cada tarea significativa
- Claude (chat) lo LEE para saber qué pasó y lo ESCRIBE para dar instrucciones
- Dispatch lo LEE para saber qué mandar y lo ACTUALIZA con confirmaciones
- Si el archivo no existe, el primer agente que actúe lo CREA
- Máximo 50 líneas — no es un log, es estado actual

---

## Protocolos por agente

### Claude (este chat) → Coordinador

**Lo que hace:**
- Planea la secuencia de tareas
- Genera prompts estructurados para Claude Code y Dispatch
- Diagnostica errores que Code o Dispatch reportan
- Crea y mejora skills
- Gestiona infra (env vars, DNS, APIs)

**Formato de salida para Claude Code:**
Cuando genere instrucciones para Code, usar este bloque:

```
━━━ PROMPT PARA CLAUDE CODE ━━━
Proyecto: {nombre}
Archivo de contexto: .claude/CONTEXT.md

OBJETIVO:
{Qué lograr en una oración}

PASOS:
1. {Paso concreto}
2. {Paso concreto}
3. {Paso concreto}

RESTRICCIONES:
- {Lo que NO hacer}

AL TERMINAR:
- Actualizar .claude/CONTEXT.md con lo que hiciste
- Reportar: {qué confirmar}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Formato de salida para Dispatch:**
Cuando genere comando para Dispatch, usar bloque corto (es móvil):

```
━━━ DISPATCH ━━━
→ {comando o instrucción en 1-2 líneas}
Proyecto: {nombre}
━━━━━━━━━━━━━━━━
```

### Claude Code → Ejecutor

**Lo que hace:**
- Lee `.claude/CONTEXT.md` ANTES de empezar cualquier tarea
- Ejecuta código, deploys, fixes
- Actualiza `.claude/CONTEXT.md` DESPUÉS de cada tarea significativa
- Si encuentra un blocker, lo escribe en la sección "Bloqueado"
- Si necesita algo de Claude (chat), lo escribe en "Notas entre agentes"

**Regla crítica:** Si Claude Code recibe una instrucción pero el CONTEXT.md dice algo diferente, **el CONTEXT.md gana**. El archivo es la fuente de verdad, no la memoria de la conversación.

### Dispatch → Control remoto

**Lo que hace:**
- Envía comandos rápidos a Claude Code desde el celular
- Lee estado actual del proyecto
- Confirma completados
- Escala a Claude (chat) cuando algo necesita planeación

**Formato de comandos Dispatch:**
Dispatch opera con comandos cortos desde móvil:

```
/status {proyecto}        → Lee CONTEXT.md y reporta
/run {instrucción}        → Ejecuta en Claude Code
/deploy {proyecto}        → Trigger redeploy en Vercel
/fix {error}              → Diagnostica y arregla
/ask {pregunta}           → Escala a Claude chat
/done {tarea}             → Marca completada en CONTEXT.md
```

---

## Handoff entre agentes

### Claude → Claude Code (lo más común)
1. Claude planea y genera el prompt estructurado
2. Luis lo copia y pega en Claude Code (o Dispatch lo envía)
3. Claude Code ejecuta y actualiza CONTEXT.md
4. Luis pega el resultado de vuelta en Claude chat si necesita seguimiento

### Claude Code → Claude (escalamiento)
1. Code encuentra algo que no puede resolver solo
2. Escribe en CONTEXT.md sección "Notas entre agentes: Code → Claude"
3. Luis pega el problema en este chat
4. Claude diagnostica y genera nuevo prompt para Code

### Dispatch → Claude Code (comando remoto)
1. Luis desde el celular manda comando via Dispatch
2. Dispatch lo traduce a instrucción para Claude Code
3. Code ejecuta y actualiza CONTEXT.md
4. Dispatch confirma a Luis en móvil

### Cualquier agente → Dispatch (notificación)
1. Tarea completada o error encontrado
2. Se actualiza CONTEXT.md
3. Dispatch puede leer el status cuando Luis consulte desde móvil

---

## Reglas de sincronización

1. **CONTEXT.md es la verdad.** No la conversación, no la memoria, no el historial de Dispatch.
2. **Leer antes de actuar.** TODO agente lee CONTEXT.md antes de empezar.
3. **Escribir después de actuar.** TODO agente actualiza CONTEXT.md al terminar.
4. **No duplicar trabajo.** Si CONTEXT.md dice que algo ya se hizo, no repetirlo.
5. **Conflictos: el timestamp más reciente gana.**
6. **Un solo agente trabaja a la vez por proyecto.** No ejecución simultánea.

---

## Setup inicial por proyecto

Cuando se inicia un proyecto nuevo o se adopta este protocolo en uno existente:

1. Crear `.claude/CONTEXT.md` con la estructura base
2. Listar las tareas actuales en "En progreso"
3. Documentar env vars pendientes
4. Definir quién tiene la siguiente acción

**Template para crear CONTEXT.md:**

```bash
mkdir -p .claude && cat > .claude/CONTEXT.md << 'EOF'
# {PROYECTO} — Context

## Estado actual
- **Fase:** setup
- **Último agente:** claude-chat
- **Última acción:** Creación de contexto inicial
- **Timestamp:** {FECHA}

## En progreso
- [ ] {Primera tarea} → asignado a: {agente}

## Completado hoy
(vacío)

## Bloqueado
(nada)

## Próximo paso
{Siguiente acción concreta}

## Env vars pendientes
| Variable | Servicio | Status |
|---|---|---|

## Notas entre agentes
(vacío)
EOF
```

---

## Ejemplo de flujo completo

**Luis en este chat:** "Necesito que VGift tenga el checkout de Mercado Pago"

**Claude (chat):**
1. Lee contexto de VGift
2. Planea: necesita env vars de MP + endpoint + webhook
3. Inyecta env vars via Vercel API
4. Genera prompt para Claude Code:

```
━━━ PROMPT PARA CLAUDE CODE ━━━
Proyecto: V-Gift (v-gift.store)
Archivo de contexto: .claude/CONTEXT.md

OBJETIVO:
Integrar checkout de Mercado Pago

PASOS:
1. Leer .claude/CONTEXT.md
2. Instalar SDK: npm i mercadopago
3. Crear /api/mercadopago/create-preference
4. Crear /api/webhooks/mercadopago
5. Crear componente CheckoutButton
6. Actualizar .claude/CONTEXT.md

RESTRICCIONES:
- No tocar auth (Clerk ya está)
- No modificar schema de Neon
- Usar env vars que ya están inyectadas

AL TERMINAR:
- Actualizar .claude/CONTEXT.md
- Confirmar que /api/webhooks/mercadopago responde 200
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Luis copia prompt → Claude Code ejecuta → Actualiza CONTEXT.md**

**Luis desde el celular (Dispatch):**
```
/status vgift
```
→ Dispatch lee CONTEXT.md → "MP integrado, webhook activo, falta test de pago real"

---

## Evolución futura

Cuando el servidor V (Flask en Hetzner) esté activo, puede servir como relay automático:
- Claude chat → POST /dispatch → V server → Claude Code subprocess
- Elimina el paso manual de copiar/pegar prompts
- Dispatch móvil → POST /dispatch → mismo flujo

Por ahora el protocolo es manual (copiar/pegar) pero la estructura ya está lista para automatizar.
