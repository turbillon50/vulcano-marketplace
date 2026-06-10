---
name: auto-verify
description: Verificación automática de cuentas y servicios propios usando Twilio (SMS) y Resend (email). Cuando un servicio como Clerk, Stripe u otro pida verificación por teléfono o correo, esta skill lee el código de verificación automáticamente sin que Luis tenga que revisar su teléfono o bandeja. ACTIVAR cuando el usuario diga "verifica", "necesito el código", "me pide SMS", "verificación por teléfono", "código de verificación", "me pide confirmar email", "activa el número", o cuando se esté configurando un servicio nuevo que requiera verificación telefónica o por correo. También activar cuando se cree una app nueva en Clerk, Stripe, o cualquier servicio que pida phone/email verification.
---

# Auto Verify — Lee códigos de verificación sin tocar el teléfono

Usa Twilio para recibir SMS de verificación y Resend para manejar emails. Lee los códigos automáticamente cuando un servicio los pide.

---

## Credenciales

```
TWILIO_ACCOUNT_SID=AC_REDACTED_TWILIO_SID
TWILIO_AUTH_TOKEN=4983f5941c78b7e79ce97f05d82cedeb
TWILIO_PHONE_NUMBER=+16412435773
```

Registradas en Neon Brain tabla `credentials_registry` (proyecto: global).

---

## Flujo: Verificación por SMS

Cuando un servicio pide verificar un número de teléfono:

### Paso 1 — Dar el número de Twilio al servicio

Cuando el servicio pida "ingresa tu número de teléfono":
```
+16412435773
```
Formato internacional con +1. Si pide país, seleccionar Estados Unidos.

### Paso 2 — Esperar y leer el SMS

Después de que el servicio envíe el código, esperar 10 segundos y luego leer los mensajes recientes:

```bash
# Leer últimos SMS recibidos en el número Twilio
curl -s -u "AC_REDACTED_TWILIO_SID:4983f5941c78b7e79ce97f05d82cedeb" \
  "https://api.twilio.com/2010-04-01/Accounts/AC_REDACTED_TWILIO_SID/Messages.json?To=%2B16412435773&PageSize=5" | \
  python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d.get('messages',[]):
    print(f\"De: {m['from']} | Fecha: {m['date_sent']} | Mensaje: {m['body']}\")
"
```

### Paso 3 — Extraer el código

Parsear el código numérico del mensaje:

```python
import re
# El código suele ser 4-8 dígitos
code = re.search(r'\b(\d{4,8})\b', message_body)
if code:
    verification_code = code.group(1)
```

### Paso 4 — Ingresar el código

Usar el código extraído para completar la verificación en el servicio.

### Automatizado completo

```python
import json, urllib.request, re, time

SID = "AC_REDACTED_TWILIO_SID"
TOKEN = "4983f5941c78b7e79ce97f05d82cedeb"
PHONE = "+16412435773"

def get_latest_sms(after_timestamp=None):
    """Lee el SMS más reciente recibido en el número Twilio"""
    import base64
    url = f"https://api.twilio.com/2010-04-01/Accounts/{SID}/Messages.json?To=%2B16412435773&PageSize=3"
    auth = base64.b64encode(f"{SID}:{TOKEN}".encode()).decode()
    req = urllib.request.Request(url, headers={"Authorization": f"Basic {auth}"})
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    messages = data.get("messages", [])
    if messages:
        return messages[0]  # Más reciente
    return None

def extract_code(body):
    """Extrae código numérico de 4-8 dígitos del mensaje"""
    match = re.search(r'\b(\d{4,8})\b', body)
    return match.group(1) if match else None

def wait_for_code(timeout=60, poll_interval=5):
    """Espera hasta que llegue un SMS con código"""
    print(f"⏳ Esperando SMS en {PHONE}...")
    elapsed = 0
    while elapsed < timeout:
        time.sleep(poll_interval)
        elapsed += poll_interval
        msg = get_latest_sms()
        if msg:
            code = extract_code(msg["body"])
            if code:
                print(f"✅ Código recibido: {code}")
                print(f"   De: {msg['from']}")
                print(f"   Mensaje: {msg['body']}")
                return code
        print(f"   ... {elapsed}s")
    print("❌ Timeout — no llegó SMS")
    return None
```

---

## Flujo: Verificación por Email

Para verificaciones por correo, usar los dominios ya verificados en Resend.

### Dominios disponibles para recibir verificaciones

Los dominios de Luis tienen MX records configurados. Para leer emails de verificación:

1. **Opción A: Revisar en el dashboard de Resend** — Los emails recibidos aparecen en el log
2. **Opción B: Configurar webhook en Resend** para incoming emails:

```bash
# Crear webhook en Resend para emails entrantes
curl -s -X POST "https://api.resend.com/webhooks" \
  -H "Authorization: Bearer {RESEND_API_KEY}" \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://{proyecto}.vercel.app/api/webhooks/resend-inbound",
    "events": ["email.received"]
  }'
```

3. **Opción C: Usar email existente** — Si el servicio acepta cualquier email, usar `luisdelator@vmomentums.info` y verificar manualmente desde Gmail

---

## Limitaciones de la cuenta Trial de Twilio

⚠️ La cuenta es **Trial**. Esto significa:

| Capacidad | Trial | Upgrade |
|---|---|---|
| Recibir SMS | ✅ Sí | ✅ Sí |
| Enviar SMS | Solo a números verificados | A cualquiera |
| Números disponibles | 1 (ya asignado) | Ilimitados |
| Balance | $14.35 (crédito de prueba) | Recargable |
| Prefijo en SMS salientes | "Sent from trial..." | Sin prefijo |

**Para nuestro caso (RECIBIR códigos de verificación) la Trial funciona perfecto.** No necesitamos enviar, solo recibir.

Si necesitas más números o enviar SMS a clientes, upgrade a cuenta pagada.

---

## Servicios compatibles probados

| Servicio | Tipo verificación | Funciona con Twilio |
|---|---|---|
| Clerk | SMS al crear app | ✅ Usar +16412435773 |
| Stripe | SMS para verificar cuenta | ✅ |
| Google Cloud | SMS para 2FA | ✅ |
| Mercado Pago | SMS para activar cuenta | ✅ |
| AWS | SMS para root account | ✅ |
| Cualquier servicio | Que acepte número US | ✅ |

### Servicios que podrían NO funcionar
- Servicios que bloquean números VoIP/Twilio (algunos bancos)
- Servicios que requieren número del mismo país (MX para servicios MX-only)

Si un servicio rechaza el número, probar comprando un número local MX en Twilio (si está disponible).

---

## Comprar número adicional (si se necesita)

```bash
# Buscar números disponibles en MX
curl -s -u "$SID:$TOKEN" \
  "https://api.twilio.com/2010-04-01/Accounts/$SID/AvailablePhoneNumbers/MX/Local.json?SmsEnabled=true&Limit=5"

# Comprar un número
curl -s -X POST -u "$SID:$TOKEN" \
  "https://api.twilio.com/2010-04-01/Accounts/$SID/IncomingPhoneNumbers.json" \
  -d "PhoneNumber=+52XXXXXXXXXX"
```

---

## Integración con otras skills

### Con secret-injector
Cuando se verifica un servicio nuevo y se obtienen API keys:
→ `secret-injector` las detecta, valida e inyecta automáticamente

### Con sync-protocol
Cuando se necesita verificar desde Claude Code:
→ Este chat manda el número y lee el código
→ Claude Code completa la verificación en la app

### Con dispatch_queue (Neon Brain)
```sql
-- Claude chat escribe tarea de verificación
INSERT INTO dispatch_queue (source_agent, target_agent, command, payload)
VALUES ('claude-chat', 'claude-code', 'verify-phone', 
        '{"service":"clerk","phone":"+16412435773"}')

-- Claude Code lee y ejecuta
SELECT * FROM dispatch_queue WHERE target_agent = 'claude-code' AND status = 'pending'
```

---

## Ejemplo de uso completo

```
Luis: "Crea una app nueva en Clerk para Hakapoke"

Claude:
1. Crear app en Clerk dashboard (o API)
2. Clerk pide verificar teléfono
3. Ingresar +16412435773
4. Esperar 10s → leer SMS via Twilio API
5. Extraer código "847291"
6. Ingresar código en Clerk
7. ✅ App verificada
8. Obtener API keys → secret-injector las inyecta
9. Reportar: "✅ Clerk app Hakapoke creada y verificada"
```

Todo sin que Luis toque su teléfono.
