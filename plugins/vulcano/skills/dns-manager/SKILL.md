---
name: dns-manager
description: Gestionar DNS records en name.com para cualquier dominio. ACTIVAR cuando se necesite configurar DNS, agregar CNAME, TXT, MX, A records, o cuando se conecte Clerk, Resend, Vercel u otro servicio que requiera DNS. CRITICO: host SIEMPRE es solo el subdominio, NUNCA incluir el dominio base.
---
# DNS Manager — name.com API

## REGLA CRITICA (aprendida por error)
En name.com API v4, el campo `host` es SOLO el subdominio:
- CORRECTO: {"host": "clerk", "type": "CNAME", ...}
- INCORRECTO: {"host": "clerk.carnesn.ink", "type": "CNAME", ...}

El dominio base se agrega automaticamente. Si pones el dominio completo, crea un record doble tipo `clerk.carnesn.ink.carnesn.ink` que NUNCA resuelve.

## Credenciales
User: turbillon50@gmail.com
Token: en Hetzner /home/secrets/global/.env (NAMECOM_TOKEN)

## API Base
https://api.name.com/v4
Auth: Basic (user:token)

## Operaciones

### Listar records
GET /domains/{domain}/records

### Crear record
POST /domains/{domain}/records
Body: {"host": "SUBDOMINIO", "type": "CNAME|TXT|MX|A", "answer": "valor", "ttl": 300}
Para MX agregar: "priority": 10

### Borrar record
DELETE /domains/{domain}/records/{record_id}

### Actualizar record
PUT /domains/{domain}/records/{record_id}

## Records standard por servicio

### Vercel
- A record: host="" answer="76.76.21.21"
- CNAME: host="www" answer="cname.vercel-dns.com"

### Clerk (5 CNAMEs)
- host="clerk" answer="frontend-api.clerk.services"
- host="accounts" answer="accounts.clerk.services"
- host="clkmail" answer="mail.{HASH}.clerk.services"
- host="clk._domainkey" answer="dkim1.{HASH}.clerk.services"
- host="clk2._domainkey" answer="dkim2.{HASH}.clerk.services"
El HASH se obtiene de la pagina de domains de Clerk production.

### Resend (3 records)
- TXT: host="resend._domainkey" answer="{DKIM_KEY_COMPLETA}"
- MX: host="send" answer="feedback-smtp.us-east-1.amazonses.com" priority=10
- TXT: host="send" answer="v=spf1 include:amazonses.com ~all"
CRITICO: obtener el valor DKIM COMPLETO de la API de Resend, no truncar.

## Verificar que funciona
dig CNAME {subdomain}.{domain} +short
dig TXT {subdomain}.{domain} +short
dig MX {subdomain}.{domain} +short

Si no resuelve pero el record existe en name.com → el host esta mal formateado.

## 24 dominios disponibles
hapicredit.live, castores.info, sagradacomunidad.digital, vforge.site, tanit.work, vmomentum.site, vliving.site, vliving.life, rivones.site, rideme.ink, breack.life, eljuegodelainteligencia.info, vcredit.club, hakapoke.ink, ruta618.life, castores.live, crede-ti.info, v-tv.site, luciennespa.beauty, lnred.ink, carnesn.ink, v-gift.store, mtempresarial.life, eternime.org

## Errores conocidos
| Error | Causa | Fix |
|---|---|---|
| Record no resuelve | Host con dominio completo | Usar SOLO subdominio |
| DKIM truncado | Valor cortado al crear | Obtener valor COMPLETO de API Resend |
| Record duplicado | Crear sin borrar anterior | Listar primero, borrar si existe |
