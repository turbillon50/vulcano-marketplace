---
name: clone-vibe
description: >
  Clona el vibe visual de cualquier URL de referencia y lo aplica a landing pages y apps.
  ACTIVAR cuando el usuario diga "clona el vibe de", "quiero que se vea como [URL]",
  "toma referencia de", "mismo estilo que", "inspírate en", "referencias visuales",
  o al trabajar en hero/landing de cualquier proyecto de Luis (VForge, Crede-ti,
  V-Gift, Eternime, Hakapoke, DANTT, RideMe, SellExperience, Ruta 618, Lu-Spa, etc.).
  Referencias validadas: neon.tech, replit.com, linear.app, vercel.com, stripe.com.
triggers:
  - clona el vibe
  - mismo estilo que
  - referencias visuales
  - inspírate en
  - referencias
---

# clone-vibe

## PROCESO
1. `curl -sL URL | python3 -c "import sys,re; html=sys.stdin.read(); [strip scripts/styles/tags]; print(text[:5000])"`
2. Extraer: headline pattern, CTAs, secciones, elementos técnicos visibles
3. Adaptar al proyecto con contenido real
4. Producir componente con `// Vibe reference: X` al inicio

## REFERENCIAS VALIDADAS

### neon.tech — Technical Dark Premium
- Fondo `#0a0a0f`, grid sutil 60px violet/10, un solo glow radial
- Headline: técnico directo, tracking -0.03em, max 12 palabras
- Subtitle: font-light text-white/55, max 2 líneas
- CTAs: botón sólido primario + ghost border-white/10
- CLI hint en monospace bajo CTAs (código real de la API)
- Feature chips: dot de color + nombre + descripción inline
- Stats bar: border-t, números mono bold, labels white/30
- Sin drama: opacity+y simple, delays 0.05s escalonados
- **Proyectos**: VForge, Crede-ti, VCredit, DANTT, cualquier SaaS técnico

### replit.com — Clean Interactive Dark
- Headline: pregunta directa al usuario
- Secciones: nombre 2 palabras + 1 línea valor + visual real del producto
- Whitespace generoso, py-20+ entre secciones
- **Proyectos**: VForge, Hakapoke, SellExperience

### linear.app — Minimal Focused Dark
- Afirmación de posicionamiento fuerte
- Features: grid 3col, ícono + título + descripción corta
- Solo tipografía, íconos y whitespace — cero ilustraciones
- **Proyectos**: Eternime, Ruta 618, Comunidad Doce, DANTT

### stripe.com — Trusted Financial
- Social proof ARRIBA del fold
- Color primario violeta/índigo
- **Proyectos**: Crede-ti, VCredit, RentameRapido, V-Gift, Lu-Spa

### vercel.com — Enterprise Minimal
- Animaciones max 0.3s, nunca bloquean contenido
- **Proyectos**: V-TV, Eternime, cualquier producto con deploy/infra

## MAPA PROYECTOS → REFERENCIA
VForge→neon+replit | Crede-ti→stripe | VCredit→stripe | V-Gift→vercel
Eternime→linear | Hakapoke→replit | RideMe→vercel | SellExperience→replit
RentameRapido→stripe | DANTT→linear | Comunidad Doce→linear | Ruta 618→vercel | Lu-Spa→stripe

## REGLAS DE ORO
1. Nunca >1 glow/blur por sección
2. Nunca esferas/orbes que tapen contenido
3. Siempre mostrar algo real: código, métricas, CLI, número de usuarios
4. Sin `min-h-screen` en hero — el contenido define la altura
5. `html` solo `overflow-x:clip` — body tiene `overflow-y:auto` (fix scroll desktop)
6. Contraste nav mínimo: `text-white/65`, nunca `text-white/40`
7. Copy directo: si tardas 3s en entender el producto → reescribe
8. Stats con números reales únicamente

## MÓDULO DE INICIO
Al arrancar cualquier sesión de frontend → cargar mentalmente:
- Estructura: replit.com | Estética: neon.tech | Copy: linear.app
- Animaciones: vercel.com | Trust/fintech: stripe.com
