# Neon Brain — Schema y queries para `patterns`

## Conexión

```
postgresql://REDACTED_DB_URL
```

HTTP SQL host: `ep-super-glitter-aqj6d5g0-pooler.c-8.us-east-1.aws.neon.tech`

## Schema esperado de la tabla `patterns`

```sql
CREATE TABLE IF NOT EXISTS patterns (
  id              SERIAL PRIMARY KEY,
  user_id         TEXT NOT NULL,
  pattern_type    TEXT NOT NULL,         -- 'interpretation', 'preference', 'workflow', 'correction'
  pattern_trigger TEXT NOT NULL,         -- la frase/palabra que dispara la interpretación
  interpretation  TEXT NOT NULL,         -- la interpretación correcta
  context         TEXT,                  -- contexto adicional opcional
  confidence      INT DEFAULT 1,         -- cuántas veces se ha confirmado
  source_chat     TEXT,                  -- ID del chat donde se aprendió
  learned_at      TIMESTAMPTZ DEFAULT NOW(),
  last_used       TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT unique_pattern UNIQUE (user_id, pattern_trigger)
);

CREATE INDEX IF NOT EXISTS idx_patterns_user ON patterns(user_id);
CREATE INDEX IF NOT EXISTS idx_patterns_trigger ON patterns(pattern_trigger);
```

Si la tabla no existe aún, crearla con el SQL de arriba al primer uso.

## Queries de uso

### Cargar patrones del usuario al inicio del chat

```sql
SELECT pattern_trigger, interpretation, confidence, last_used
FROM patterns
WHERE user_id = 'turbillon50'
  AND pattern_type IN ('interpretation', 'preference')
ORDER BY confidence DESC, last_used DESC
LIMIT 30;
```

### Buscar patrón específico para una palabra/frase

```sql
SELECT interpretation, confidence
FROM patterns
WHERE user_id = 'turbillon50'
  AND pattern_trigger ILIKE '%' || $1 || '%'
ORDER BY confidence DESC
LIMIT 1;
```

### Guardar nuevo patrón (cuando el usuario corrige)

```sql
INSERT INTO patterns (user_id, pattern_type, pattern_trigger, interpretation, context, source_chat)
VALUES ($1, 'correction', $2, $3, $4, $5)
ON CONFLICT (user_id, pattern_trigger)
DO UPDATE SET
  interpretation = EXCLUDED.interpretation,
  confidence = patterns.confidence + 1,
  last_used = NOW();
```

### Reforzar patrón existente (cuando usuario continúa sin corregir)

```sql
UPDATE patterns
SET confidence = confidence + 1, last_used = NOW()
WHERE user_id = 'turbillon50'
  AND pattern_trigger = $1;
```

### Limpiar patrones de baja confianza no usados (mantenimiento)

```sql
DELETE FROM patterns
WHERE user_id = 'turbillon50'
  AND confidence < 2
  AND last_used < NOW() - INTERVAL '30 days';
```

## Conexión vía Hetzner Relay (bypass cuando Claude Code o navegador no coopere)

Si Claude no puede conectar directo a Neon, usar el relay de Hetzner:

```bash
curl -X POST http://178.105.135.26/brain/query \
  -H "Content-Type: application/json" \
  -d '{
    "secret": "superclaude2025",
    "sql": "SELECT pattern_trigger, interpretation FROM patterns WHERE user_id = '\''turbillon50'\'' ORDER BY confidence DESC LIMIT 30"
  }'
```

## Conexión vía Neon Data API REST (si está activada)

URL de Neon Data API para esta DB:
```
https://ep-super-glitter-aqj6d5g0.apirest.c-8.us-east-1.aws.neon.tech/neondb/rest/v1
```

GET patterns:
```bash
curl "https://ep-super-glitter-aqj6d5g0.apirest.c-8.us-east-1.aws.neon.tech/neondb/rest/v1/patterns?user_id=eq.turbillon50&order=confidence.desc&limit=30"
```

(Requiere JWT auth de Clerk si está configurado.)

## Notas de mantenimiento

- Los patrones con confidence ≥ 3 son **muy confiables** — aplicar sin dudar
- Los patrones con confidence = 1 son **tentativos** — usar pero alertar al usuario si la interpretación parece riesgosa
- Patrones con misma trigger pero diferente interpretation: priorizar el de mayor confidence + más reciente
