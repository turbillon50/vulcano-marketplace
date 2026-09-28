---
name: integrate-stripe
description: Integrar Stripe pagos en cualquier proyecto. Crear productos, precios, payment links, webhooks, suscripciones. ACTIVAR cuando el usuario diga pagos, stripe, cobrar, suscripcion, checkout, payment link, o cuando un proyecto necesite procesamiento de pagos.
---
# Integrate Stripe

## Credenciales
- STRIPE_SECRET_KEY en Hetzner /home/secrets/global/.env
- Cuenta: V-Pay (MX, MXN, charges+payouts enabled)

## Flujo para nuevo proyecto
1. Crear producto: POST /v1/products {name, description}
2. Crear precio: POST /v1/prices {product, unit_amount en centavos, currency, recurring si aplica}
3. Crear payment link: POST /v1/payment_links {line_items}
4. Crear webhook: POST /v1/webhook_endpoints {url, enabled_events[]}
5. Guardar webhook secret (whsec_) en Hetzner + Brain
6. Inyectar env vars en Vercel: STRIPE_SECRET_KEY, NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY, STRIPE_WEBHOOK_SECRET

## Eventos webhook standard
- checkout.session.completed -> fulfill order
- payment_intent.succeeded -> confirmar pago
- payment_intent.payment_failed -> notificar fallo
- charge.refunded -> procesar reembolso
- invoice.paid -> suscripcion renovada
- customer.subscription.deleted -> suscripcion cancelada

## API patterns
Auth: -u sk_live_REDACTED: (basic auth, password vacio)
Montos: siempre en centavos (49900 = $499.00 MXN)
Currency: mxn para Mexico

## Payment Link vs Checkout Session
- Payment Link: URL estatica reutilizable, ideal para compartir
- Checkout Session: URL unica por transaccion, ideal para apps con carrito
