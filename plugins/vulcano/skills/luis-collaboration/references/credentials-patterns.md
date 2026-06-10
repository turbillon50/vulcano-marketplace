# Patrones de credenciales por proveedor

Para identificar rápidamente si una key pegada por Luis es de qué proveedor.

| Proveedor | Formato típico | Ejemplo |
|---|---|---|
| **Anthropic** | `sk-ant-api03-...` | sk-ant-api03-AbCdEf... |
| **OpenAI** | `sk-proj-...` o `sk-...` (legacy) | sk-proj-abc... |
| **Google Gemini / AI Studio (legacy)** | `AIzaSy...` (~40 chars) | AIzaSyABC123... |
| **Google Gemini / AI Studio (workspace nuevo)** | `AQ.Ab8RN6...` | AQ.Ab8RN6LhGLMUs... |
| **Google OAuth access tokens** | `ya29....` o `AQ.Ab8...` | ya29.a0AfH6SM... |
| **Google Stitch / Mariner** | `AQ.Ab8RN6...` (similar a Gemini) | usar X-Goog-Api-Key header |
| **ElevenLabs** | `sk_...` (formato hexadecimal largo) | sk_f611644c279792117... |
| **Stripe** | `sk_live_...` / `pk_live_...` / `whsec_...` | sk_live_REDACTED... |
| **Resend** | `re_...` | re_MBMbKDZX_LEG... |
| **Clerk** | `pk_live_...` / `sk_live_...` / `whsec_...` | pk_live_REDACTED... |
| **Reloadly** | Client ID alfanumérico + Secret largo | cayuJil2OQqpCBH3VL1qn6M3Dn7swQBq |
| **Duffel** | `duffel_REDACTED...` / `duffel_REDACTED...` | duffel_REDACTED... |
| **Viator** | UUID v4 (8-4-4-4-12) | 9b329562-0d22-40bc-9f47-b19c4a513eec |
| **Mapbox** | `pk.eyJ1...` (JWT) | pk.eyJ1IjoibHVpc2RlbGF0... |
| **Vercel** | `vcp_...` (account) / `vck_...` (other) | vcp_5ly0R8W6pbf6b... |
| **Neon** | `napi_...` | napi_6gz101bv1440i... |
| **GitHub** | `ghp_...` / `gho_...` / `ghs_...` | ghp_abcdef123... |
| **Cloudflare** | API tokens son hex largos (40 chars) | abc123def456... |

## Pasos de validación inmediata por proveedor

### Anthropic
```bash
curl -H "x-api-key: $KEY" -H "anthropic-version: 2023-06-01" \
  https://api.anthropic.com/v1/messages \
  -H "Content-Type: application/json" \
  -d '{"model":"claude-opus-4-7","max_tokens":50,"messages":[{"role":"user","content":"hi"}]}'
```

### Gemini
```bash
curl "https://generativelanguage.googleapis.com/v1beta/models?key=$KEY"
# Esperar HTTP 200 con lista de modelos
```

### Stripe
```bash
curl -u "$SK_LIVE:" https://api.stripe.com/v1/account
```

### Clerk
```bash
curl -H "Authorization: Bearer $SK" https://api.clerk.com/v1/users?limit=1
```

### Resend
```bash
curl -H "Authorization: Bearer $KEY" https://api.resend.com/domains
```

### ElevenLabs
```bash
curl -H "xi-api-key: $KEY" https://api.elevenlabs.io/v1/user
```

### Reloadly (3 audiences, 1 token cada uno)
```bash
curl -X POST https://auth.reloadly.com/oauth/token \
  -H "Content-Type: application/json" \
  -d "{\"client_id\":\"$ID\",\"client_secret\":\"$SECRET\",\"grant_type\":\"client_credentials\",\"audience\":\"https://giftcards.reloadly.com\"}"
```

### Duffel
```bash
curl -H "Authorization: Bearer $KEY" -H "Duffel-Version: v2" \
  https://api.duffel.com/air/airports?limit=1
```

### Viator
```bash
curl -H "exp-api-key: $KEY" -H "Accept: application/json;version=2.0" \
  https://api.viator.com/partner/destinations
```

### Vercel
```bash
curl -H "Authorization: Bearer $TOKEN" https://api.vercel.com/v2/user
```

### Neon
```bash
curl -H "Authorization: Bearer $KEY" https://console.neon.tech/api/v2/projects
```

## Si la key no funciona

1. **HTTP 401 / Invalid auth** → key incorrecta, vencida o rotada
2. **HTTP 403** → key válida pero sin permisos para ese endpoint
3. **HTTP 429** → quota / rate limit → verificar billing (caso clásico de Gemini free tier)
4. **HTTP 503** → servicio temporalmente saturado (Gemini Flash con alta demanda)
5. **Connection timeout** → revisar firewall del sandbox; algunas TCP están bloqueadas

Si Luis pega algo y NO autentica, **pedirle confirmación con formato exacto antes de descartar** — caso real: la key de Gemini con formato nuevo `AQ.Ab8...` parecía OAuth pero era API key válida.
