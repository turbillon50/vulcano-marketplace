# luis-collaboration skill

Skill personalizada que captura cómo trabajar con Luis Delator en su infraestructura.
Estilo, tono, patrones técnicos y contexto de todos sus proyectos.

## ¿Qué hace esta skill?

Cuando se carga en Claude Code (o se referencia desde cualquier instancia de Claude que
soporte skills), automáticamente:

- Adopta el tono mexicano casual que prefieres ("hermano", "va", "al toque")
- Sigue el patrón **acción primero, narración después**
- Conoce todo el stack técnico de tus proyectos (Castores, Crede-ti, V-Gift, Eternime, etc.)
- Aplica los patrones validados de DNS, Vercel, Neon, Clerk, Stripe, Reloadly, Duffel, Viator, Resend, ElevenLabs, Gemini
- Evita trampas del entorno bash/sh
- Reconoce momentos de peso emocional y baja el ritmo apropiadamente

## Instalación

### Opción 1: Claude Code local (recomendado)

Si trabajas con Claude Code en tu máquina o en Hetzner:

```bash
# Crear directorio de skills si no existe
mkdir -p ~/.claude/skills

# Copiar la skill
cp -r luis-collaboration ~/.claude/skills/

# Verificar
ls ~/.claude/skills/luis-collaboration/
# Debe mostrar: SKILL.md, references/
```

Claude Code la carga automáticamente la próxima vez que arranques. No hay paso de
activación adicional — el motor de skills la descubre por el frontmatter `name` y
la activa cuando el contexto coincide con la descripción.

### Opción 2: En tu servidor Hetzner (V/Flask app)

Si quieres que tu Flask app "V" en `v-forge` referencie la skill al invocar
Claude Code vía subprocess:

```bash
# En el servidor Hetzner
ssh hetzner

# Crear directorio compartido para skills
sudo mkdir -p /opt/claude-skills
sudo chown $USER:$USER /opt/claude-skills

# Subir la skill (desde tu máquina local)
scp -r luis-collaboration hetzner:/opt/claude-skills/

# Configurar Flask app V para apuntar a este directorio
# En el archivo de la app que llama a Claude Code:
export CLAUDE_PROJECT_DIR=/opt/claude-skills
# o usar el flag --skills-dir si tu versión de Claude Code lo soporta
```

Luego en cualquier endpoint que invoque Claude Code, el contexto de la skill
se carga automáticamente cuando el modelo identifica que la conversación
involucra alguno de tus proyectos.

### Opción 3: Empaquetada como `.skill`

Si tienes el archivo `luis-collaboration.skill` (zip empaquetado), simplemente:

```bash
# Doble click en macOS / Linux con Claude Code instalado
# O importar desde la UI de Claude.ai (Settings → Skills → Upload)
```

## Cómo verificar que está funcionando

En un nuevo chat con Claude (o sesión de Claude Code), prueba:

```
"Hola, necesito configurar Neon para un proyecto nuevo"
```

Si la skill está activa, la respuesta debería:
- Empezar con tono casual ("Va hermano...")
- Mencionar que sabe que estás en Vercel team `team_gK8RSuGh0CYHEjgEqFRR2iIk`
- Ofrecer crear el proyecto en `aws-us-east-1` por default
- Usar HTTP SQL (no TCP) para habilitar pgvector
- Reportar con tabla markdown

Si no, la skill no está cargando — revisa que esté en `~/.claude/skills/` y reinicia Claude Code.

## Cómo actualizar la skill

A medida que aprendas patrones nuevos o tus proyectos evolucionen:

1. Edita directamente `~/.claude/skills/luis-collaboration/SKILL.md`
2. O las referencias en `references/`
3. Los cambios se aplican en el siguiente turno (no requiere reinicio en Claude Code reciente)

Si quieres sugerencia: pídele a Claude que actualice la skill después de un sprint
exitoso con "Actualiza la skill luis-collaboration con lo que aprendimos hoy".

## Estructura

```
luis-collaboration/
├── SKILL.md                              # Comportamiento principal
└── references/
    ├── projects.md                       # Detalle de cada proyecto activo
    └── credentials-patterns.md           # Identificación de API keys por proveedor
```

## Versionado

- v1.0 — Inicial (2026-06-01). Captura el sprint de configuración de Eternime
  y los aprendizajes de los proyectos previos (V-Gift, Crede-ti, Ruta 618,
  Castores, etc.)
