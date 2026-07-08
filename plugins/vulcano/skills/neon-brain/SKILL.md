---
name: neon-brain
description: Base de datos Neon Postgres como memoria persistente y semántica para todo el ecosistema Claude. Reemplaza archivos BRAIN.md, PATTERNS.md y CONTEXT.md dispersos con UNA base de datos centralizada consultable desde cualquier chat, Claude Code o Dispatch. ACTIVAR cuando el usuario diga "qué sabes de", "busca en tu memoria", "recuerdas que", "guarda esto", "registra", "actualiza el estado", "qué proyectos tengo", "cuántas skills hay", "historial", "qué patrones conoces", "brain", "memoria", o cuando cualquier agente necesite consultar o almacenar contexto persistente. También activar al inicio de sesión para cargar contexto del proyecto activo. Esta skill es el UPGRADE de turbo-boot — en vez de leer archivos markdown, consulta una base de datos real.
---

# Neon Brain — Memoria persistente para Claude

Una base de datos Postgres en Neon que funciona como cerebro permanente. Cualquier instancia de Claude (chat, Code, Dispatch) puede leer y escribir. Lo que se aprende en una conversación, se sabe en todas.

---

## Filosofía

> **Claude no olvida. Todo lo que resuelve, aprende, configura o descubre queda en la base.**

No más markdown disperso. No más "¿ya habíamos hecho esto?". Una sola fuente de verdad queryable.

---

## Conexión

```
Host: {NEON_HOST}
Database: claude_brain
User: claude_brain_owner
Password: {PASSWORD}
Connection string: postgresql://REDACTED_DB_URL
```

### Cómo consultar (HTTP SQL — funciona en CUALQUIER entorno)

```bash
curl -s -X POST "https://{NEON_HOST}/sql" \
  -H "Content-Type: application/json" \
  -H "Neon-Connection-String: {CONNECTION_STRING}" \
  -d '{"query": "SELECT * FROM projects WHERE active = true"}'
```

**REGLA:** Siempre usar HTTP SQL, nunca TCP 5432 (bloqueado en sandbox de Claude).

**REGLA:** Una sentencia por query. No separar con `;`.

---

## Schema

### Tabla: projects
Estado de cada proyecto del ecosistema.

```sql
CREATE TABLE projects (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    domain TEXT,
    vercel_project_id TEXT,
    github_repo TEXT,
    stack JSONB DEFAULT '{}',
    phase TEXT DEFAULT 'setup' CHECK (phase IN ('setup','dev','demo','integration','production')),
    active BOOLEAN DEFAULT true,
    last_agent TEXT,
    last_action TEXT,
    next_step TEXT,
    blocked TEXT,
    env_vars JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

Ejemplo de `stack`:
```json
{"framework":"nextjs","auth":"clerk","db":"neon","payments":"stripe","email":"resend"}
```

Ejemplo de `env_vars` (solo metadata, NUNCA valores reales):
```json
{
  "STRIPE_SECRET_KEY": {"status":"active","service":"stripe","injected":"2025-06-02"},
  "DATABASE_URL": {"status":"active","service":"neon","injected":"2025-06-01"},
  "RESEND_API_KEY": {"status":"pending","service":"resend"}
}
```

### Tabla: skills
Registry de todas las skills disponibles.

```sql
CREATE TABLE skills (
    name TEXT PRIMARY KEY,
    version TEXT DEFAULT '1.0',
    description TEXT NOT NULL,
    agents TEXT[] DEFAULT ARRAY['code'],
    triggers TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: patterns
Cache de soluciones — el PATTERNS.md pero queryable.

```sql
CREATE TABLE patterns (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    problem TEXT NOT NULL,
    cause TEXT,
    fix TEXT NOT NULL,
    applies_to TEXT[],
    tags TEXT[],
    times_used INTEGER DEFAULT 1,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: tasks
Tareas activas y completadas por proyecto.

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    project_id TEXT REFERENCES projects(id),
    description TEXT NOT NULL,
    assigned_to TEXT DEFAULT 'unassigned' CHECK (assigned_to IN ('claude-chat','claude-code','dispatch','unassigned')),
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending','in_progress','blocked','done','cancelled')),
    priority INTEGER DEFAULT 5 CHECK (priority BETWEEN 1 AND 10),
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    completed_at TIMESTAMPTZ
);
```

### Tabla: conversations
Resúmenes comprimidos de conversaciones importantes.

```sql
CREATE TABLE conversations (
    id SERIAL PRIMARY KEY,
    project_id TEXT REFERENCES projects(id),
    agent TEXT NOT NULL,
    summary TEXT NOT NULL,
    decisions TEXT[],
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

### Tabla: credentials_registry
Registro de QUÉ credenciales existen DÓNDE (nunca los valores).

```sql
CREATE TABLE credentials_registry (
    id SERIAL PRIMARY KEY,
    project_id TEXT REFERENCES projects(id),
    service TEXT NOT NULL,
    env_var_name TEXT NOT NULL,
    environment TEXT[] DEFAULT ARRAY['production','preview','development'],
    status TEXT DEFAULT 'active' CHECK (status IN ('active','expired','revoked','pending')),
    vercel_injected BOOLEAN DEFAULT false,
    hetzner_synced BOOLEAN DEFAULT false,
    last_validated TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Queries frecuentes (copiar y usar)

### Al iniciar sesión — cargar contexto

```sql
SELECT name, domain, phase, last_action, next_step, blocked, stack
FROM projects WHERE active = true ORDER BY updated_at DESC
```

### Buscar un patrón antes de debuggear

```sql
SELECT title, fix FROM patterns
WHERE tags @> ARRAY['webhook'] OR problem ILIKE '%307%'
ORDER BY times_used DESC LIMIT 5
```

### Ver tareas pendientes de un proyecto

```sql
SELECT description, assigned_to, priority FROM tasks
WHERE project_id = 'vgift' AND status IN ('pending','in_progress')
ORDER BY priority ASC
```

### Registrar que se resolvió algo

```sql
INSERT INTO patterns (title, problem, cause, fix, applies_to, tags)
VALUES (
    'Webhook 307 en Vercel',
    'Clerk/Stripe webhook devuelve 307 redirect',
    'Vercel trailing slash redirect',
    'trailingSlash: false en next.config + ruta sin / final',
    ARRAY['castores','vgift','crede-ti'],
    ARRAY['webhook','vercel','clerk','stripe','307']
)
```

### Actualizar estado de proyecto

```sql
UPDATE projects SET
    phase = 'dev',
    last_agent = 'claude-code',
    last_action = 'Integrado Mercado Pago checkout',
    next_step = 'Crear webhook endpoint',
    updated_at = NOW()
WHERE id = 'vgift'
```

### Ver todas las skills

```sql
SELECT name, version, description FROM skills ORDER BY name
```

### Guardar resumen de conversación

```sql
INSERT INTO conversations (project_id, agent, summary, decisions)
VALUES (
    'vgift',
    'claude-chat',
    'Planeación de integración MP. Se definió flujo: preference → checkout → webhook → confirmación.',
    ARRAY['Usar MP sandbox primero','Webhook en /api/webhooks/mercadopago','No tocar auth existente']
)
```

### Buscar en la memoria (semántico por texto)

```sql
SELECT * FROM conversations
WHERE summary ILIKE '%mercado pago%'
ORDER BY created_at DESC LIMIT 5
```

---

## Protocolo de uso por agente

### Claude (chat) — Coordinador

**Al iniciar conversación:**
```
1. Query: proyectos activos
2. Query: tareas pendientes del proyecto mencionado
3. Query: últimos patterns relevantes
→ Ya tienes contexto completo sin que Luis explique nada
```

**Al terminar conversación:**
```
1. INSERT en conversations (resumen + decisiones)
2. UPDATE en projects (last_action, next_step)
3. INSERT en tasks (nuevas tareas generadas)
```

### Claude Code — Ejecutor

**Al iniciar sesión:**
```
1. Query: proyecto actual (por directorio o nombre)
2. Query: tareas asignadas a 'claude-code' pendientes
3. Query: patterns relevantes al stack del proyecto
→ Arranca sabiendo qué hacer sin leer 10 archivos
```

**Al terminar tarea:**
```
1. UPDATE task → status = 'done'
2. UPDATE project → last_action, next_step
3. INSERT pattern si resolvió bug no obvio
```

### Dispatch — Control remoto

**Comandos:**
```
/status → SELECT from projects WHERE id = ?
/tasks → SELECT from tasks WHERE project_id = ? AND status = 'pending'
/done {task_id} → UPDATE tasks SET status = 'done' WHERE id = ?
/brain {query} → SELECT from conversations WHERE summary ILIKE ?
```

---

## Integración con turbo-boot

`turbo-boot` puede reemplazar la lectura de BRAIN.md con un query:

```sql
-- Un solo query que devuelve todo el contexto de arranque
SELECT
    p.name, p.domain, p.phase, p.stack, p.next_step, p.blocked, p.env_vars,
    (SELECT COUNT(*) FROM tasks t WHERE t.project_id = p.id AND t.status = 'pending') as pending_tasks,
    (SELECT json_agg(json_build_object('name',s.name,'version',s.version))
     FROM skills s) as available_skills
FROM projects p
WHERE p.id = '{PROJECT_ID}'
```

Un query, todo el BRAIN. No archivos, no parsing, no tokens desperdiciados.

---

## Integración con skill-factory

Cuando skill-factory crea una skill nueva:

```sql
INSERT INTO skills (name, version, description, agents, triggers)
VALUES (
    'integrate-mercadopago',
    '1.0',
    'Integrar Mercado Pago en proyecto Next.js',
    ARRAY['code'],
    ARRAY['mercado pago','pagos','checkout MX']
)
```

La skill queda registrada y cualquier agente la encuentra.

---

## Integración con secret-injector

Cuando se inyecta una credencial:

```sql
INSERT INTO credentials_registry (project_id, service, env_var_name, vercel_injected, hetzner_synced, last_validated)
VALUES ('vgift', 'stripe', 'STRIPE_SECRET_KEY', true, true, NOW())
ON CONFLICT (project_id, env_var_name)
DO UPDATE SET status = 'active', vercel_injected = true, last_validated = NOW()
```

---

## Upgrade futuro: memoria semántica con pgvector

Cuando quieras buscar por significado, no solo por texto:

```sql
CREATE EXTENSION IF NOT EXISTS vector;

ALTER TABLE conversations ADD COLUMN embedding vector(3072);
ALTER TABLE patterns ADD COLUMN embedding vector(3072);

-- Indexar para búsqueda rápida
CREATE INDEX ON conversations USING hnsw (embedding vector_cosine_ops);
CREATE INDEX ON patterns USING hnsw (embedding vector_cosine_ops);
```

Flujo:
1. Generar embedding con Gemini embedding-001 (3072 dims)
2. Guardar en columna `embedding`
3. Buscar con:
```sql
SELECT summary, 1 - (embedding <=> $1::vector) as similarity
FROM conversations
ORDER BY embedding <=> $1::vector
LIMIT 5
```

Esto convierte la memoria de "buscar por texto" a "buscar por significado". "¿Qué conversaciones tuve sobre pagos?" encontrará resultados aunque nunca hayas usado la palabra "pagos".

---

## Inicialización (una sola vez)

### Paso 1: Crear proyecto en Neon

```bash
curl -s -X POST "https://console.neon.tech/api/v2/projects" \
  -H "Authorization: Bearer {NEON_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{"project":{"name":"claude-brain","pg_version":17,"region_id":"aws-us-east-1"}}'
```

### Paso 2: Ejecutar schema

Ejecutar cada CREATE TABLE por separado via HTTP SQL (una por query).

### Paso 3: Poblar datos iniciales

Insertar proyectos existentes, skills del vault, y patterns conocidos.

### Paso 4: Distribuir connection string

- Inyectar `CLAUDE_BRAIN_URL` en todos los proyectos de Vercel
- Guardar en Hetzner
- Guardar en memory de Claude chat

---

## Seguridad

- **NUNCA guardar valores de secrets en la DB** — solo metadata (nombre, servicio, status)
- **Connection string del brain** es la ÚNICA credencial que todos los agentes necesitan
- **Read-heavy, write-light** — la mayoría de operaciones son SELECTs
- **No exponer la DB públicamente** — solo via HTTP SQL con connection string
