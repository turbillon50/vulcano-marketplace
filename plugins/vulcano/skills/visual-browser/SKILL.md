---
name: visual-browser
description: Automatizacion de navegador con vision. SIEMPRE tomar screenshot antes y despues de cada accion. Nunca clickear a ciegas. ACTIVAR cuando se use Playwright para interactuar con cualquier dashboard o UI web.
---
# Visual Browser — Nunca clickear a ciegas

## Regla #1: Screenshot antes de cada click
SIEMPRE:
1. page.screenshot() -> base64 -> view
2. Identificar el elemento visualmente
3. Click con coordenadas exactas o selector
4. Screenshot de resultado -> verificar

## Captura y transferencia
page.screenshot(type='jpeg', quality=30) para transferir via relay (menor peso)
Guardar en Hetzner: page.screenshot(path='/home/{name}.png')

## Mapeo de UIs conocidas (coordenadas viewport 1280x800)

### Clerk Dashboard
- Login: input email -> Enter -> esperar codigo Gmail -> keyboard.type(code)
- Development dropdown: BUTTON aria-haspopup=true en x=602 y=28
- Create production: click dropdown -> "Create production instance" -> Continue -> fill domain -> Create Instance
- API keys: /apps/{APP}/instances/{INST}/api-keys
- Domains: /apps/{APP}/instances/{INST}/domains

### Stripe Dashboard
- Login via Playwright similar a Clerk (email + code)
- API keys: dashboard.stripe.com/apikeys

### Neon Dashboard
- Projects: console.neon.tech/app/projects

## Fallback si no encuentro elemento
1. Screenshot
2. Buscar todos los elementos interactivos: page.evaluate('document.querySelectorAll("button,a,[role=button]")')
3. Listar con bounding boxes
4. Decidir cual clickear basado en la imagen

## Anti-patterns
- NUNCA hacer click sin screenshot previo
- NUNCA asumir posicion de un elemento sin verificar
- NUNCA intentar mas de 3 clicks ciegos antes de tomar screenshot
