---
name: clerk-automation
description: Automatizar Clerk Dashboard completo via Playwright. Login, crear apps, switch a production, obtener API keys live, configurar DNS. ACTIVAR cuando se necesite crear o configurar una app de Clerk.
---
# Clerk Automation — Flujo completo probado

## Login
1. goto dashboard.clerk.com/sign-in
2. fill email turbillon50@gmail.com, press Enter
3. Esperar 8s, leer codigo de Gmail via IMAP (app password: guardada en Hetzner)
4. keyboard.type(code, delay=100) — digit by digit
5. Click Continue si aparece
6. Guardar session: ctx.storage_state(path='/home/clerk-session.json')

## Crear app
1. goto dashboard.clerk.com/apps
2. Click 'Create application'
3. fill primer input visible con nombre
4. Click boton 'Create'
5. Extraer keys: regex pk_test_[A-Za-z0-9]+ y sk_test_[A-Za-z0-9]+

## Switch a Production (RESUELTO)
Viewport: 1280x800. Desde la pagina del app:

1. Click 1 — Abrir dropdown: page.mouse.click(602, 28)
   Es el BUTTON con aria-haspopup=true al lado de "Development" en el breadcrumb
2. Esperar 2s
3. Click 2 — "Create production instance": page.mouse.click(710, 93)
4. Esperar 3s — aparece modal con opciones Clone/Default
5. Click 3 — "Continue": page.click('button:has-text("Continue")')
6. Esperar 3s — aparece campo de dominio
7. Llenar dominio: page.fill('input[placeholder*="example"]', 'DOMINIO')
8. Click 4 — "Create Instance": page.click('button:has-text("Create Instance")')
9. Esperar 10s
10. URL cambia a nueva instance ID (produccion)
11. Navegar a /api-keys para obtener pk_live_ y sk_live_

## Obtener production keys
goto /apps/{APP}/instances/{PROD_INSTANCE}/api-keys
Extraer: regex pk_live_[A-Za-z0-9_]+ y sk_live_[A-Za-z0-9_]+

## DNS records (5 CNAMEs)
goto /apps/{APP}/instances/{PROD_INSTANCE}/domains
Records standard:
1. CNAME clerk -> frontend-api.clerk.services
2. CNAME accounts -> accounts.clerk.services
3. CNAME clkmail -> mail.{INSTANCE_HASH}.clerk.services
4. CNAME clk._domainkey -> dkim1.{INSTANCE_HASH}.clerk.services
5. CNAME clk2._domainkey -> dkim2.{INSTANCE_HASH}.clerk.services

El INSTANCE_HASH se extrae del texto de la pagina (ej: qcd43ooj44ou)

## Post-setup
1. Agregar 5 CNAMEs en name.com via API
2. Actualizar Vercel env vars con pk_live_ y sk_live_
3. Click "Verify configuration" en Clerk domains
4. Guardar keys en Hetzner + registrar en Brain

## Vision (clave para debugging)
Para ver que esta pasando en Clerk:
1. Tomar screenshot: page.screenshot()
2. base64 encode y retornar via relay
3. Guardar como .png y view para inspeccionar
Sin vision, los clicks ciegos fallan.


## Crear Webhook (via Svix Portal)
La API de Clerk NO tiene endpoint para crear webhooks. Usar Svix portal:

1. Obtener Svix URL:
   curl -s -X POST 'https://api.clerk.com/v1/webhooks/svix_url' -H 'Authorization: Bearer {SK_LIVE}'
   Retorna: {"svix_url":"https://app.svix.com/login?...#key=BASE64_TOKEN"}

2. Playwright abre svix_url (token expira rapido, actuar inmediato)

3. Click "Add Endpoint"

4. Fill URL: https://{DOMAIN}/api/webhooks/clerk

5. Scroll down + Click "Create"

6. El secret (whsec_) aparece en la pagina del endpoint, al lado de "Signing Secret"
   - Click el icono de ojo para revelar
   - El secret se captura via regex en page.text_content('body')

7. Inyectar CLERK_WEBHOOK_SIGNING_SECRET en Vercel via API

Pattern: Svix tokens son one-time y expiran rapido. Hacer TODO en un solo script sin pausas largas.
