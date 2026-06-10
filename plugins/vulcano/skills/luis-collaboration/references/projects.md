# Proyectos de Luis Delator — referencia detallada

Estado actualizado al 2026-06-01. Usar como contexto cuando se trabaje en cualquiera.

## Activos en producción / desarrollo activo

### 1. Castores Store (`castores.live`)
- **Vercel project:** `v0-castores-store-frontend` (`prj_Wp55qomlC1S4Vpf1aWq7DSXJKFPn`)
- **Tipo:** B2B/B2C ecommerce de suministros eléctricos/industriales
- **Stack:** Next.js, Drizzle, Stripe LIVE, Clerk, Reloadly (futuro)
- **Estado:** Env vars completas (12); pendientes Mercado Pago + Resend
- **Stripe keys:** `pk_live_REDACTED...` (cuenta global reusable)

### 2. Crede-ti (`crede-ti.info`)
- **Vercel project:** `hapicredit-api-server` (`prj_QLWTB8ZuFyb8W8YjR8Os90MX9D28`)
- **Repo:** `turbillon50/hapicredit` (privado, monorepo)
- **Tipo:** Fintech con role-based panels (admin / agente / cliente)
- **Estado:** Env vars completas; **PENDIENTE:** ejecutar real schema (17 tablas) desde `initial_schema.sql` commit `cbd406c`
- **Webhook URL recomendado:** `https://hapicredit-api-server.vercel.app/api/webhooks/clerk` (vercel.app evita el 307 issue)
- **Admin elevation:** publicMetadata `{"role":"admin"}` desde Clerk dashboard, o key `credite/credeti` en `/perfil`

### 3. Ruta 618 (`ruta618.life`)
- **Vercel project:** `v0-ruta-618-app` (`prj_StxJnIE59QTaGSkXUFPkOpe7097a`)
- **Tipo:** PWA driver con GPS tracking, fleet management
- **Stack:** Next.js, Clerk, Neon, Mapbox, IndexedDB para offline
- **Estado:** Env vars completas (10), Code trabajando

### 4. V-Gift (`v-gift.store`)
- **Vercel project:** `v-gift` (`prj_ili7eogJiMeLbTPGt7IdqnyV0rLc`)
- **Tipo:** Marketplace de regalos (gift cards + vuelos + tours + recargas + servicios)
- **Stack completo:** 30 env vars activas — Clerk, Neon, Stripe LIVE, Reloadly LIVE, Duffel LIVE, Viator Basic (Full+Booking pending), Resend, Blob, branding
- **Viator shop URL:** `https://www.viator.com/partner-shop/vgift`
- **Audiencias:** B2C + B2B (empresas regalan a empleados)
- **Idiomas:** ES + EN
- **Estado:** Infra lista, esperando código de Code

### 5. Eternime (`eternime.org`)
- **Vercel project:** `eternime-lobby` (`prj_N8BFhVecSucuqw23lrqM9FpmyLGR`)
- **Repo:** `turbillon50/eternime-lobby` (privado)
- **Tipo:** Bóveda digital de memoria personal con IA — proyecto inicialmente personal, posible producto futuro
- **Visión:** Captura continua durante la vida + IA personal que aprende y eventualmente representa
- **Stack:** Next.js, Clerk, Neon + pgvector, Vercel Blob, Gemini AI (Flash 3.5 + Pro 2.5 + embedding-001), Resend, ElevenLabs Creator
- **Estado:** 17 env vars listas, Code construyendo lobby cinematográfico
- **Nombre:** Riesgo trademark con proyecto histórico (Marius Ursache 2014). Decisión de Luis: seguir, "si me demandan que me compren el dominio".
- **Modelo de uso inicial:** Personal (Luis), después decide si abrir

### 6. Hakapoke (`hakapoke.ink`)
- **Vercel project:** `v0-restaurant-pwa` (`prj_p5x4chCoVJqJmyuEXTLc2vLT7yoB`)
- **Tipo:** Restaurant PWA con menú real scrapeado de Uber Eats
- **Estado:** Live; pendiente integración Resend

### 7-10. Otros activos
- **V-TV** (`v-tv.site`) — completado
- **Lu-Spa** (`luciennespa.beauty`) — live, sin env vars de pago aún
- **DANTT / Lnred** (`lnred.ink`) — festival cashless NFC; env vars completas (11), pendiente Mercado Pago + Resend
- **VForge** — no-code app builder
- **Comunidad Doce** — faith-based leadership app (deployed con HTML files originales)
- **Dinero Sucio** — board game adaptation digital (TypeScript)

### 11+. Dominios verificados en Resend pero estado desconocido
- `alix-ai.net`, `raumer.online`, `sellexperience.live`, `mymomentum.live`, `rideme.ink`, `vcredit.club`, `sagradacomunidad.digital`, `rentamerapido.autos`, `vandefi.org`

## Servidor Hetzner

- **Nombre:** `v-forge`
- **Aplicación:** Flask "V" que actúa como bridge a Claude Code vía subprocess
- **Endpoint principal:** `/claude` (protegido por UFW firewall)
- **Pattern:** Verificación log-based de interacciones V↔Claude

## Skills personales de Luis (en Claude Code)

- `design-fidelity` — SKILL.md + Python scripts para reproducción pixel-perfect de diseños propios. Incluye color extraction, typography matching, visual diff.

## Issues técnicos conocidos pendientes

- `/api/webhooks/*` retorna HTTP 307 en producción para algunos proyectos — workaround: usar URL `vercel.app` directa en lugar del dominio custom para registrar webhooks en Clerk/Stripe
