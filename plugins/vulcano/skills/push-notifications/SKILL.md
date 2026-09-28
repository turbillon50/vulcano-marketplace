---
name: push-notifications
description: Configurar Web Push (VAPID) + emails transaccionales (Resend) para cualquier proyecto PWA. ACTIVAR cuando se necesiten notificaciones push, emails de bienvenida, alertas al usuario, o cuando un proyecto nuevo necesite comunicarse con sus usuarios. Genera VAPID keys, configura Resend domain + DNS, e inyecta env vars en Vercel.
---
# Push Notifications — VAPID + Resend

## Qué es VAPID
Protocolo nativo de Web Push. Permite mandar notificaciones al celular del usuario desde una PWA sin App Store ni Firebase. Gratis, sin intermediarios.

## Setup automático para cualquier proyecto

### 1. Generar VAPID keys
En Hetzner: npx web-push generate-vapid-keys
Parsear: "Public Key:" y "Private Key:" del output

### 2. Configurar Resend domain
POST https://api.resend.com/domains -H 'Authorization: Bearer {RESEND_API_KEY}' -d '{"name":"DOMINIO"}'
Obtener DNS records de la respuesta.

### 3. DNS en name.com (REGLA: solo subdominio como host)
- TXT resend._domainkey -> {DKIM_COMPLETO}
- MX send -> feedback-smtp.us-east-1.amazonses.com (priority 10)
- TXT send -> v=spf1 include:amazonses.com ~all
Verificar con dig despues de crear.

### 4. Inyectar en Vercel
NEXT_PUBLIC_VAPID_PUBLIC_KEY = {public_key} (plain)
VAPID_PRIVATE_KEY = {private_key} (encrypted)
VAPID_SUBJECT = mailto:soporte@{dominio}
RESEND_API_KEY = re_... (encrypted)
RESEND_FROM_EMAIL = {App Name} <hola@{dominio}>

### 5. Trigger Resend verification
POST https://api.resend.com/domains/{domain_id}/verify

### 6. Redeploy Vercel

## Proyectos que necesitan esto
- Ruta 618 ✅ (ya configurado)
- CSN Carnes Selectas (para alertas de pedidos)
- RideMe (para ofertas de viaje en tiempo real)
- Transport Jalisco (alertas de ruta)
- V-Gift (recordatorios de regalo)
- Cualquier PWA nueva
