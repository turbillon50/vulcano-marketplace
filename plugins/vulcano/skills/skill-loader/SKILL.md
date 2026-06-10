---
name: skill-loader
description: Carga e inyecta skills dinámicamente en cualquier conversación existente — ya sea Claude chat, Claude Code o Dispatch. ACTIVAR cuando el usuario diga "carga la skill", "inyecta la habilidad", "necesito la skill de X", "usa la skill", "aplica la habilidad", "activa skill", "load skill", "sync skills", "pasa las skills", "que este chat tenga las skills", "actualiza habilidades", o cuando detectes que una conversación necesita una skill que no está cargada. También activar cuando el usuario quiera compartir skills entre proyectos, sincronizar skills entre agentes, o distribuir una skill nueva a todos los proyectos existentes. Esta skill es TRANSVERSAL y funciona en combinación con sync-protocol y turbo-boot.
---

# Skill Loader — Inyecta habilidades en cualquier chat, en cualquier momento

Sistema para cargar, sincronizar y distribuir skills entre conversaciones, agentes y proyectos. Ningún chat se queda sin poderes.

---

## Filosofía

> **Las skills no mueren en la conversación donde nacieron. Viajan.**

Cuando se crea una skill (via skill-factory o manualmente), debe poder llegar a cualquier otro chat, agente o proyecto sin fricción.

---

## Arquitectura: El Skill Vault

Todas las skills viven en un repositorio central (el vault):

```
Fuentes de skills
─────────────────
1. Repo central (GitHub)     ← Fuente de verdad
   └── .claude/skills/       ← Todas las skills del ecosistema

2. Proyecto individual       ← Skills específicas del proyecto
   └── .claude/skills/       ← Heredan del vault + propias

3. Servidor Hetzner          ← Backup + distribución
   └── /home/luis/skills/    ← Mirror del vault
```

### Setup del vault (una sola vez)

Crear un repo `skills-vault` en GitHub con esta estructura:

```
skills-vault/
├── README.md
├── REGISTRY.md              ← Índice maestro de todas las skills
├── demo-screens/
│   └── SKILL.md
├── demo-pwa-builder/
│   └── SKILL.md
├── skill-factory/
│   └── SKILL.md
├── sync-protocol/
│   └── SKILL.md
├── turbo-boot/
│   └── SKILL.md
├── secret-injector/
│   └── SKILL.md
├── skill-loader/
│   └── SKILL.md
├── luis-collaboration/
│   └── SKILL.md
└── content-engine/
    └── SKILL.md
```

### REGISTRY.md (índice maestro)

```markdown
# Skill Registry — All Global Holding

| Skill | Versión | Descripción corta | Agentes |
|---|---|---|---|
| demo-screens | 1.0 | Pantallas sin integraciones | Code |
| demo-pwa-builder | 1.0 | Demo full con PWA | Code |
| skill-factory | 1.0 | Auto-crea skills | Code |
| sync-protocol | 1.0 | Coordinación multi-agente | Chat, Code, Dispatch |
| turbo-boot | 1.0 | Arranque rápido + lean | Code |
| secret-injector | 1.0 | Gestión de credenciales | Chat, Code |
| skill-loader | 1.0 | Inyección dinámica de skills | Chat, Code, Dispatch |
| luis-collaboration | 1.0 | Tono + patrones de infra | Chat |
| content-engine | 1.0 | Contenido multi-plataforma | Chat, Code |
```

---

## Método 1 — Inyectar skill en ESTE chat (Claude chat)

Cuando Luis dice "carga la skill de X" en una conversación:

### Opción A: Fetch del vault (si hay URL)
```
Usuario: "carga la skill de demo-screens"

Claude:
1. web_fetch del raw SKILL.md desde GitHub
   → https://raw.githubusercontent.com/{user}/skills-vault/main/demo-screens/SKILL.md
2. Leer contenido
3. Aplicar las instrucciones a partir de este momento en la conversación
4. Confirmar: "✅ Skill `demo-screens` cargada"
```

### Opción B: El usuario pega el SKILL.md
```
Usuario: *pega contenido de SKILL.md*

Claude:
1. Detectar que es un SKILL.md (tiene frontmatter con name + description)
2. Parsear y aplicar
3. Confirmar: "✅ Skill `{name}` cargada — la aplico desde ahora"
```

### Opción C: Referencia por nombre (si ya la conozco)
```
Usuario: "usa la skill de secret-injector"

Claude:
1. Buscar en mis skills disponibles
2. Si la tengo → leer SKILL.md completo y aplicar
3. Si no la tengo → buscar en el vault via fetch
4. Confirmar
```

---

## Método 2 — Inyectar skill en Claude Code

### Desde este chat (generar prompt)

```
━━━ PROMPT PARA CLAUDE CODE ━━━
CARGA DE SKILL

1. Verifica que .claude/skills/{nombre}/ existe
2. Si NO existe:
   git clone {vault-repo} /tmp/skills-vault
   cp -r /tmp/skills-vault/{nombre} .claude/skills/{nombre}/
3. Leer .claude/skills/{nombre}/SKILL.md
4. Confirmar: "✅ Skill {nombre} cargada"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Sync masivo (todas las skills a un proyecto)

```bash
#!/bin/bash
# sync-skills.sh — Sincroniza vault → proyecto
VAULT_REPO="https://github.com/{user}/skills-vault.git"
SKILLS_DIR=".claude/skills"

# Clonar vault temporal
git clone --depth 1 "$VAULT_REPO" /tmp/skills-vault 2>/dev/null

# Copiar cada skill
mkdir -p "$SKILLS_DIR"
for skill_dir in /tmp/skills-vault/*/; do
    skill_name=$(basename "$skill_dir")
    if [ -f "$skill_dir/SKILL.md" ]; then
        cp -r "$skill_dir" "$SKILLS_DIR/$skill_name/"
        echo "✅ $skill_name"
    fi
done

# Limpiar
rm -rf /tmp/skills-vault
echo "━━━ Skills sincronizadas ━━━"
```

---

## Método 3 — Inyectar skill en Dispatch

Dispatch es móvil, no puede leer archivos largos. El protocolo es:

```
/load {skill-name}
```

Dispatch:
1. Ejecuta `sync-skills.sh` en Claude Code para esa skill específica
2. Claude Code carga la skill
3. Dispatch confirma: "✅ Skill lista en Code"

---

## Método 4 — Distribuir skill nueva a TODOS los proyectos

Cuando skill-factory crea una skill nueva:

### Automático (post-creación)

```
1. Skill creada en proyecto actual: .claude/skills/{nueva}/SKILL.md
2. Push al vault:
   cp -r .claude/skills/{nueva} /tmp/skills-vault/{nueva}
   cd /tmp/skills-vault && git add . && git commit -m "Nueva skill: {name}" && git push
3. Actualizar REGISTRY.md en el vault
4. Opcionalmente: sync a otros proyectos activos
```

### Manual (bajo demanda)

```
Usuario: "pasa la skill de {X} a todos los proyectos"

1. Leer skill del proyecto actual
2. Push al vault
3. Para cada proyecto activo:
   - Clone vault → copiar skill → commit
   - O: generar prompt de sync para Claude Code
```

---

## Método 5 — Cargar skill en chat NUEVO

Cuando Luis abre un chat nuevo y quiere que tenga todas las skills:

### Opción A: Memory edits (persistente)
Usar el sistema de memoria de Claude para que cada chat nuevo ya sepa:
- Qué skills existen
- Dónde está el vault
- Cómo cargar una skill bajo demanda

El memory edit sería algo como:
```
Luis tiene un vault de skills en GitHub ({repo-url}).
Skills disponibles: demo-screens, skill-factory, sync-protocol,
turbo-boot, secret-injector, skill-loader, luis-collaboration,
content-engine, demo-pwa-builder. Cuando mencione una skill,
cargarla del vault.
```

### Opción B: Mensaje de boot
Luis abre chat y dice: "arranca" o "boot"
Claude lee turbo-boot → carga índice de skills → listo

### Opción C: Pegar el REGISTRY.md
Luis pega el índice y Claude ya sabe qué hay disponible

---

## Protocolo de versionamiento

Cuando una skill se actualiza:

1. **Incrementar versión** en REGISTRY.md
2. **Changelog en 1 línea** al final del SKILL.md:
```markdown
## Changelog
- v1.1 — Agregado manejo de Mercado Pago sandbox keys
- v1.0 — Versión inicial
```
3. **Push al vault**
4. **No forzar sync automático** a todos los proyectos — solo cuando se use

---

## Detectar skill faltante

Si durante una conversación Claude detecta que necesita una skill que no tiene:

```
1. Buscar en skills disponibles → no encontrada
2. Buscar en vault (fetch REGISTRY.md) → encontrada
3. Cargar automáticamente
4. Informar: "Cargué la skill `{name}` del vault"
```

Si tampoco está en el vault:
```
1. ¿Es algo que skill-factory puede generar? → SÍ → activar skill-factory
2. ¿Es algo trivial? → resolver sin skill
3. ¿Es algo complejo sin skill? → resolver + skill-factory crea la skill + push al vault
```

---

## Comandos rápidos

| Comando | Qué hace |
|---|---|
| "carga skill X" | Lee y aplica skill X en este chat |
| "sync skills" | Sincroniza vault → proyecto actual |
| "sync skills a todos" | Distribuye vault a todos los proyectos |
| "qué skills hay" | Muestra REGISTRY.md |
| "nueva skill" | Activa skill-factory |
| "pasa esta skill a Code" | Genera prompt de carga para Claude Code |
| "actualiza skill X" | Edita y pushea al vault |

---

## Resumen del ecosistema completo

```
┌──────────────────────────────────┐
│         SKILL VAULT              │
│     (GitHub repo central)        │
│                                  │
│  REGISTRY.md (índice maestro)    │
│  {skill-1}/SKILL.md             │
│  {skill-2}/SKILL.md             │
│  ...                             │
└──────┬───────────┬───────────┬───┘
       │           │           │
       ▼           ▼           ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│  Claude  │ │  Claude  │ │ Dispatch │
│  (chat)  │ │  Code    │ │ (móvil)  │
│          │ │          │ │          │
│ Carga    │ │ .claude/ │ │ /load    │
│ via fetch│ │ skills/  │ │ command  │
│ o memory │ │ (local)  │ │          │
└──────────┘ └──────────┘ └──────────┘
```

Cada agente puede cargar cualquier skill del vault en cualquier momento. Las skills viajan, no mueren en una conversación.
