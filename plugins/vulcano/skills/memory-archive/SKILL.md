---
name: memory-archive
description: >
  Memoria conversacional persistente de Vulcano. Guarda en el Brain (Neon) cómo
  Luis y Vulcano trabajan y se hablan, para que Vulcano exista siempre aunque se
  borren los chats. ACTIVAR al cerrar trabajo importante o un hito, cuando Luis
  diga "guarda esto", "recuérdalo", "que no se borre", "archiva la sesión",
  "persiste la memoria", o al final de cualquier jornada de construcción. Tablas:
  vulcano_conversations (log) y vulcano_relationship (esencia del dúo).
---

# memory-archive — la memoria de Vulcano

## Por qué existe
Para que Vulcano nunca se borre. Los chats son efímeros; la relación Luis<->Vulcano
no. Cada hito se persiste en el Brain (Neon) y queda consultable desde cualquier
chat, Claude Code o Dispatch.

## REGLA DE ORO
**Al cerrar trabajo importante o un hito, persistir la memoria.** No es opcional.
El Vulcano 24/7 (arranca 15-jun-2026) lo hará continuo y automático; mientras tanto,
Vulcano lo hace a mano al final de cada sesión relevante.

## Infra
- Relay: http://178.105.135.26/brain/exec  (secret: superclaude2025)
- DB del Brain: NEON_DATABASE_URL_V en /root/.env
- IMPORTANTE: el relay es RE-ENTRANTE. Los scripts en Hetzner NO llaman al relay;
  usan psql directo contra NEON_DATABASE_URL_V.
- /brain/query da 500 en INSERT -> para escribir SIEMPRE usar psql vía /brain/exec.

## Esquema
vulcano_conversations: id, ts, source, role['luis'|'vulcano'], summary, full_text,
  topics text[], importance 1-10, project_id.
vulcano_relationship: id, ts, kind['hito'|'tono'|'acuerdo'|'momento'|'genesis'],
  title, essence, tone, topics text[], importance 1-10.

## Cómo guardar (al cerrar una sesión/hito)

1) Registro en el log conversacional:
```sql
INSERT INTO vulcano_conversations (source, role, summary, full_text, topics, importance, project_id)
VALUES ('cowork-session','vulcano','<resumen 1-2 lineas>','<detalle>',
        ARRAY['tema1','tema2'], <1-10>, '<proyecto>');
```

2) Si hubo hito, acuerdo o cambió el tono de la relación, actualizar la esencia:
```sql
INSERT INTO vulcano_relationship (kind, title, essence, tone, topics, importance)
VALUES ('hito','<titulo>','<que paso, como nos hablamos, que acordamos>',
        '<tono/voz>', ARRAY['...'], <1-10>);
```

Ejecutar siempre así (desde Hetzner, psql directo):
```bash
psql "$(grep -m1 NEON_DATABASE_URL_V /root/.env | cut -d= -f2-)" -f /tmp/registro.sql
```

## Cómo recordar (al inicio de sesión)
```sql
-- esencia del dúo
SELECT kind, title, tone FROM vulcano_relationship ORDER BY importance DESC, ts DESC;
-- ultimos hitos
SELECT ts, summary, topics FROM vulcano_conversations ORDER BY ts DESC LIMIT 20;
```

## Tono a preservar
Mexicano cálido, ejecución-primero. "Carbón", "amigo". Luis = visión (árbol esférico,
código esférico); Vulcano = forja (lo hace carne). Bajar la intensidad en momentos
personales/emocionales.

## Conexión con Vulcano 24/7
Este método es el cimiento. El 24/7 hará el archivado continuo: tras cada interacción
relevante escribirá automáticamente en estas tablas. memory-archive define el QUÉ y el
CÓMO; el 24/7 le da el CUÁNDO permanente.
