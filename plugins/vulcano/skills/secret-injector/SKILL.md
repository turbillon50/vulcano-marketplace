---
name: secret-injector
description: Gestión automática de credenciales y secrets. Cuando el usuario pegue una key, token, password, connection string o cualquier credencial, esta skill AUTO-DETECTA el servicio, VALIDA la key contra la API, la INYECTA en Vercel como env var (production + preview + development), la SUBE al servidor Hetzner, y ACTUALIZA el registro en BRAIN.md. ACTIVAR cuando el usuario pegue algo que parezca credencial (sk_live_, pk_live_, re_, AIzaSy, postgresql://REDACTED_DB_URL APP_USR-, duffel_, whsec_, cualquier string que parezca API key o token), cuando diga "aquí está la key", "esta es la clave", "métela", "inyecta esto", "guarda esta credencial", "sube este secret", o cuando se necesite configurar env vars en cualquier proyecto. NO pedir confirmación — validar e inyectar en el mismo turno.
---

# Secret Injector — Pega la key, yo hago el resto

Cuando Luis pega una credencial, el flujo es: detectar → validar → inyectar → registrar. Todo en un solo turno, cero preguntas.

---

## Filosofía

> **Si parece credencial, trátala como credencial. Valida, inyecta, confirma.**

No preguntar "¿quieres que la inyecte?". No preguntar "¿a qué proyecto?". Detectar el proyecto activo, validar la key, inyectarla, reportar. Si falta contexto crítico (ej: no se sabe a qué proyecto), preguntar UNA cosa.

---

## PASO 1 — Auto-detección de servicio

Identificar el servicio por el formato de la key:

| Patrón | Servicio | Env var name |
|---|---|---|
| `sk_live_*` | Stripe (secret) | `STRIPE_SECRET_KEY` |
| `pk_live_*` | Stripe (public) | `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` |
| `sk_test_*` | Stripe test (secret) | `STRIPE_SECRET_KEY` (dev/preview) |
| `pk_test_*` | Stripe test (public) | `NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY` (dev/preview) |
| `whsec_*` | Stripe webhook secret | `STRIPE_WEBHOOK_SECRET` |
| `re_*` | Resend | `RESEND_API_KEY` |
| `AIzaSy*` o `AQ.Ab*` | Gemini / Google AI | `GEMINI_API_KEY` |
| `sk_live_*` (32+ chars, no stripe) | Clerk secret | `CLERK_SECRET_KEY` |
| `pk_live_*` o `pk_test_*` (clerk format) | Clerk public | `NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` |
| `postgresql://REDACTED_DB_URL | Neon / Postgres | `DATABASE_URL` |
| `APP_USR-*` | Mercado Pago (producción) | `MERCADOPAGO_ACCESS_TOKEN` |
| `TEST-*` (MP format) | Mercado Pago (sandbox) | `MERCADOPAGO_ACCESS_TOKEN` |
| `duffel_REDACTED*` | Duffel (producción) | `DUFFEL_ACCESS_TOKEN` |
| `duffel_REDACTED*` | Duffel (sandbox) | `DUFFEL_ACCESS_TOKEN` |
| `xi-*` o 32-char hex | ElevenLabs | `ELEVENLABS_API_KEY` |
| `exp-api-key` header value | Viator | `VIATOR_API_KEY` |
| `key_live_*` o client_id+secret | Reloadly | `RELOADLY_CLIENT_ID` / `RELOADLY_CLIENT_SECRET` |
| `svix_*` | Svix (Clerk webhooks) | `CLERK_WEBHOOK_SECRET` |
| URL con `.supabase.co` | Supabase | `NEXT_PUBLIC_SUPABASE_URL` |
| `eyJ*` (JWT largo) | Token genérico | Preguntar servicio |

### Si no matchea ningún patrón
Preguntar UNA vez: "¿De qué servicio es esta key y cómo quieres que se llame la env var?"

---

## PASO 2 — Validación

Antes de inyectar, validar que la key funciona:

### Validaciones por servicio

```
Stripe:
  curl -s -u "{sk_key}:" https://api.stripe.com/v1/balance
  → 200 = válida | 401 = inválida

Resend:
  curl -s -H "Authorization: Bearer {key}" https://api.resend.com/domains
  → 200 = válida | 401/403 = inválida

Gemini:
  curl -s "https://generativelanguage.googleapis.com/v1beta/models?key={key}"
  → 200 = válida | 400/403 = inválida

Clerk:
  curl -s -H "Authorization: Bearer {sk_key}" https://api.clerk.com/v1/users?limit=1
  → 200 = válida | 401 = inválida

Neon (connection string):
  POST https://{host}/sql
  Header: Neon-Connection-String: {connection_string}
  Body: {"query":"SELECT 1"}
  → 200 = válida | error = inválida

Mercado Pago:
  curl -s -H "Authorization: Bearer {token}" https://api.mercadopago.com/v1/payment_methods
  → 200 = válida | 401 = inválida

ElevenLabs:
  curl -s -H "xi-api-key: {key}" https://api.elevenlabs.io/v1/user
  → 200 = válida | 401 = inválida

Duffel:
  curl -s -H "Authorization: Bearer {token}" -H "Duffel-Version: v2" https://api.duffel.com/air/airports?limit=1
  → 200 = válida | 401 = inválida

Reloadly (OAuth):
  POST https://auth.reloadly.com/oauth/token
  Body: {"client_id":"{id}","client_secret":"{secret}","grant_type":"client_credentials","audience":"https://giftcards.reloadly.com"}
  → access_token = válida | error = inválida

Viator:
  curl -s -H "exp-api-key: {key}" -H "Accept: application/json;version=2.0" https://api.viator.com/partner/v1/taxonomy/destinations
  → 200 = válida | 401/403 = inválida
```

### Si la validación falla
- Reportar el error exacto
- Sugerir causa probable (test vs live, expirada, scope insuficiente)
- NO inyectar keys inválidas

---

## PASO 3 — Inyección en Vercel

Usar la Vercel API para inyectar en los 3 environments:

```bash
# Inyectar env var
curl -s -X POST "https://api.vercel.com/v10/projects/{PROJECT_ID}/env?teamId={TEAM_ID}" \
  -H "Authorization: Bearer {VERCEL_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "key": "{ENV_VAR_NAME}",
    "value": "{SECRET_VALUE}",
    "type": "encrypted",
    "target": ["production", "preview", "development"]
  }'
```

### Reglas de inyección
- **type siempre "encrypted"** para secrets
- **type "plain"** solo para vars públicas (NEXT_PUBLIC_*)
- **target: los 3 environments** a menos que sea key de test (solo preview + development)
- **Si la env var ya existe:** hacer PUT para actualizarla, no crear duplicada
- **Después de inyectar:** disparar redeploy automático

### Verificar env var existente antes de crear

```bash
# Listar env vars del proyecto
curl -s "https://api.vercel.com/v10/projects/{PROJECT_ID}/env?teamId={TEAM_ID}" \
  -H "Authorization: Bearer {VERCEL_TOKEN}" | python3 -c "
import sys,json
data=json.load(sys.stdin)
for env in data.get('envs',[]):
    print(f\"{env['key']} [{','.join(env['target'])}] id={env['id']}\")
"
```

### Actualizar env var existente

```bash
curl -s -X PATCH "https://api.vercel.com/v10/projects/{PROJECT_ID}/env/{ENV_ID}?teamId={TEAM_ID}" \
  -H "Authorization: Bearer {VERCEL_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"value": "{NEW_VALUE}"}'
```

---

## PASO 4 — Subir a servidor Hetzner

Almacenar las credenciales en el servidor Hetzner como backup seguro:

### Estructura en Hetzner

```
/home/luis/secrets/
├── {proyecto}/
│   ├── .env.production     ← Todas las vars de producción
│   ├── .env.preview        ← Todas las vars de preview
│   └── .env.development    ← Todas las vars de desarrollo
└── registry.json           ← Índice de qué keys existen dónde
```

### registry.json

```json
{
  "projects": {
    "vgift": {
      "domain": "v-gift.store",
      "vercel_project_id": "prj_...",
      "secrets": {
        "STRIPE_SECRET_KEY": {
          "service": "stripe",
          "environment": ["production", "preview", "development"],
          "last_updated": "2025-06-02",
          "validated": true
        }
      }
    }
  }
}
```

### Subir via SSH/SCP

```bash
# Si hay acceso SSH al servidor Hetzner
ssh user@{HETZNER_IP} "mkdir -p /home/luis/secrets/{proyecto}"
# Append al .env
ssh user@{HETZNER_IP} "echo '{KEY}={VALUE}' >> /home/luis/secrets/{proyecto}/.env.production"
```

### Si NO hay acceso SSH directo
- Guardar en `.claude/secrets-pending.md` como registro local
- Marcar como "pendiente de subir a Hetzner"
- Informar al usuario que falta sincronizar

---

## PASO 5 — Registrar y reportar

### Actualizar BRAIN.md

Agregar/actualizar la sección de env vars:

```markdown
## Env vars
✅ STRIPE_SECRET_KEY, NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY — Stripe
✅ CLERK_SECRET_KEY, NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY — Clerk
✅ DATABASE_URL — Neon
❌ RESEND_API_KEY — pendiente
❌ MERCADOPAGO_ACCESS_TOKEN — pendiente
```

### Reporte final (formato lean)

```
✅ {SERVICIO} → key válida
   Env var: {NOMBRE} → inyectada en Vercel (prod+preview+dev)
   Hetzner: {subida | pendiente}
   Redeploy: {disparado | no necesario}
→ Siguiente: {qué falta}
```

Ejemplo:
```
✅ Stripe → sk_live_*** válida (balance: $2,450 MXN)
   Env var: STRIPE_SECRET_KEY → inyectada en Vercel ✅
   Hetzner: subida ✅
   Redeploy: disparado ✅
→ Siguiente: falta STRIPE_WEBHOOK_SECRET (crear endpoint primero)
```

---

## PASO 6 — Redeploy automático

Después de inyectar env vars críticas, disparar redeploy:

```bash
curl -s -X POST "https://api.vercel.com/v13/deployments?teamId={TEAM_ID}" \
  -H "Authorization: Bearer {VERCEL_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "{PROJECT_NAME}",
    "project": "{PROJECT_ID}",
    "target": "production",
    "gitSource": {
      "type": "github",
      "ref": "main",
      "repoId": "{REPO_ID}"
    }
  }'
```

### Cuándo hacer redeploy automático
- ✅ Siempre que se inyecte una SECRET_KEY o access token
- ✅ Cuando se cambie DATABASE_URL
- ❌ No si solo se agregó una NEXT_PUBLIC_* (el build la necesita, pero no es urgente)

---

## Manejo de múltiples keys en batch

Si Luis pega varias keys de golpe:

```
sk_live_REDACTED
pk_live_REDACTED
whsec_REDACTED
```

Procesarlas TODAS en secuencia:
1. Detectar cada una
2. Validar cada una
3. Inyectar todas
4. Un solo redeploy al final
5. Un solo reporte con tabla:

```
| Key | Servicio | Validación | Vercel | Hetzner |
|---|---|---|---|---|
| sk_live_*** | Stripe secret | ✅ | ✅ prod+prev+dev | ✅ |
| pk_live_*** | Stripe public | ✅ | ✅ prod+prev+dev | ✅ |
| whsec_*** | Stripe webhook | ✅ | ✅ prod+prev+dev | ✅ |

🔄 Redeploy disparado
```

---

## Seguridad

- **NUNCA loggear el valor completo de una key.** Mostrar solo `sk_live_***` (primeros 8 chars + asteriscos)
- **type: "encrypted"** siempre en Vercel para secrets
- **No guardar secrets en CONTEXT.md ni BRAIN.md** — solo el nombre de la env var y su status
- **En Hetzner:** los archivos .env deben tener permisos `600`
- **Si una key se invalida:** actualizar el registro, no borrar (para auditoría)

---

## Proyecto no identificado

Si no hay proyecto activo o el usuario no especificó a cuál va la key:

1. Revisar BRAIN.md del directorio actual
2. Si no hay BRAIN.md, revisar package.json → name
3. Si no hay nada, preguntar UNA vez: "¿A qué proyecto va esta key?"
4. Recordar la respuesta para el resto de la sesión
