---
name: demo-pwa-builder
description: Transformar un repositorio recién importado (descargado de Google Stitch, Figma make, v0, lovable, bolt, o cualquier diseño front-end) en una PWA demo cinematográfica con 3 modos navegables (público, usuario, admin), toggle flotante, datos demo plausibles, y experiencia que cierre clientes en presentaciones. ACTIVAR SIEMPRE que el usuario diga "demo", "convertir esto en demo", "PWA de venta", "para mostrar al cliente", "transforma este Stitch", "presentación al cliente", "demo para vender", o cuando detectes archivos crudos de Google Stitch (HTML estático sin routing, sin auth, sin DB) en un repo recién clonado. También activar cuando el usuario describa un flujo donde necesita mostrar a un prospecto cómo se vería su app antes de contratarte. La skill produce una experiencia end-to-end en una sola corrida sin pedir confirmaciones intermedias.
---

# Demo PWA Builder — Transforma Stitch en demo que vende

Esta skill convierte el output crudo de Google Stitch (o equivalente: Figma Make, v0, lovable, bolt, simples archivos HTML) en una PWA demo cinematográfica diseñada para CERRAR clientes en presentaciones de 5-10 minutos.

## Cuándo aplicar esta skill

Activar automáticamente cuando:
- El usuario diga "convertir en demo", "transforma esto en una demo", "PWA para vender"
- Detectes un repo con archivos estáticos crudos (HTML + CSS + assets sin lógica) que vino de Google Stitch o similar
- El usuario mencione "presentación al cliente", "para cerrar", "demo que venda"
- El repo se llame con patrón `demo-*`, `*-demo`, `pwa-demo-*`

Si el usuario solo quiere fix puntual o feature pequeña, esta skill NO aplica.

---

## Misión

Producir, en una sola corrida sin pausas, una PWA demo de calidad Silicon Valley con 3 modos navegables (público / usuario / admin), toggle flotante, datos plausibles del vertical detectado, animaciones que vendan y PWA real instalable. El objetivo es que el prospecto pase de "estoy viendo" a "¿cuánto cuesta?" en 5 minutos.

---

## Reglas no negociables

- **Cero pausas para confirmar.** Si hay ambigüedad, toma la decisión más profesional y ambiciosa visualmente. Documenta en `TODO:` solo decisiones contradictorias del input.
- **Llegar de principio a fin.** No paréntesis ni "cuando termines esto avísame". Ejecutar el flujo completo y entregar URL de preview al final.
- **Stack obligatorio:** Next.js 16 App Router + TypeScript estricto (cero `any`) + Tailwind v4 + shadcn/ui + Framer Motion + Lucide React.
- **Idioma default:** español mexicano profesional (sin "vos", sin "lo cogió", textos serios y persuasivos).
- **Branch de trabajo:** `claude/demo-pwa-v1`. Al final, abrir PR draft contra `main` con título descriptivo.
- **Cliente target:** prospecto que va a decidir contratar después de la demo. La demo es ventas, no exhibición técnica.

---

## Fase 0 — Análisis del input

Antes de escribir UNA línea de código, leer TODO el contenido del repo y producir `/STITCH_ANALYSIS.md` con:

- **Vertical de negocio detectado** (ecommerce, fintech, SaaS, marketplace, agency, restaurante, inmobiliaria, app móvil, salud, educación, otro)
- **Paleta de colores** (extraer hex codes exactos del CSS; mínimo: primary, secondary, accent, background, foreground, muted)
- **Tipografía** (familia + pesos usados; si Stitch usaba Google Fonts, conservar; si no, decidir: Inter + Cal Sans para display, o equivalente premium)
- **Tono visual** (corporativo, startup, luxury, friendly, minimalista, brutalista, neo-brutalismo, glassmorphism)
- **Componentes ya armados** (hero, cards, forms, footer, etc.)
- **Audiencia probable del producto final** (B2B, B2C, prosumer)

Este análisis informa todas las decisiones siguientes. NO saltar este paso.

---

## Fase 1 — Estructura

1. Crear estructura Next.js 16 App Router con TypeScript estricto
2. Configurar Tailwind v4 con tema custom basado en la paleta de Fase 0
3. Instalar shadcn/ui + Framer Motion + Lucide React + Recharts + canvas-confetti + react-parallax-tilt
4. Crear `/lib/design-tokens.ts` con colors, spacing, radius, shadows, animations
5. Soportar light + dark mode con toggle visible
6. Crear `/lib/demo-data/*.ts` con tipos estrictos para todos los datos demo

---

## Fase 2 — Modo PÚBLICO (landing / marketing)

Lo que ve cualquier visitante sin loguearse. Tiene que generar el WOW inmediato.

### Páginas mínimas

| Ruta | Contenido |
|---|---|
| `/` | Home cinematográfica (hero + 3-5 secciones) |
| `/como-funciona` | 3-4 steps animados |
| `/precios` | 3 planes con comparativa y CTAs |
| `/casos-de-exito` | 3 casos con métricas plausibles |
| `/contacto` | Form fake + información de contacto |
| `/sign-in`, `/sign-up` | Forms con UX premium |

### Componentes obligatorios

- Hero con animación de entrada (gradient mesh animado, parallax sutil, o video loop fake si encaja)
- Badge `"Trusted by 500+ businesses"` con logos placeholder elegantes (SVGs custom simples o servicio como `logo.clearbit.com` para marcas reales si encaja con el vertical)
- Sección de features con micro-interacciones al hover (tilt 3D sutil, glow, scale)
- Testimonios con avatars realistas (usar `pravatar.cc/150?img=N`)
- Stats grandes con CountUp al hacer scroll (`$2.4M procesados`, `12,000 usuarios activos`, `99.9% uptime`)
- Footer completo con links de legal, social, soporte

---

## Fase 3 — Modo USUARIO (cliente del producto)

Lo que vería el usuario final del producto que el cliente vende. Demuestra que SÍ vamos a construir la app real.

### Páginas mínimas (adaptar al vertical detectado)

| Ruta | Contenido |
|---|---|
| `/app` | Dashboard personalizado del usuario |
| `/app/perfil` | Perfil + configuración de cuenta |
| `/app/[feature-1]` | Función principal del producto (hacer pedido, ver portafolio, agendar cita, enviar regalo, etc.) |
| `/app/[feature-2]` | Función secundaria importante |
| `/app/historial` | Historial de actividad / transacciones |
| `/app/notificaciones` | Centro de notificaciones con items realistas |

### Componentes obligatorios

- Sidebar/topbar consistente con modo público pero adaptado a app
- Avatar y nombre del usuario demo (`Sofía Hernández` o `Mateo Rivera`)
- Skeleton loaders durante "cargas" simuladas (delays 600-1200ms)
- Charts con recharts (line, bar, donut) con datos plausibles
- Tablas con paginación, filtros y búsqueda (data static seedeada)
- Modales con interacciones reales (crear/editar/borrar items)
- Toasts cuando se completan acciones
- Empty states ilustrados para secciones vacías

---

## Fase 4 — Modo ADMIN (operador del negocio)

Lo que ve el cliente que está contratándonos. Esto les vende el "yo controlo todo desde aquí".

### Páginas mínimas

| Ruta | Contenido |
|---|---|
| `/admin` | Dashboard ejecutivo con KPIs grandes |
| `/admin/usuarios` | Tabla de usuarios/clientes con CRUD |
| `/admin/[entidad-1]` | Gestión de entidad principal (productos / pedidos / agentes / lo que aplique) |
| `/admin/[entidad-2]` | Otra entidad importante |
| `/admin/reportes` | 3 reportes con gráficas grandes + export CSV |
| `/admin/configuracion` | Settings con tabs (general / branding / pagos / equipo / notificaciones) |
| `/admin/equipo` | Gestión de roles internos |

### Componentes obligatorios

- KPIs grandes con tendencia (`↑ +12.4% vs mes anterior`) y mini-charts
- Data tables pro (sort, filter, bulk actions, pagination)
- Filtros laterales colapsables
- Modales side-sheet para detalles de cualquier item
- Acciones bulk (seleccionar varios, exportar, archivar)
- Badges de estado con colores semánticos
- Activity log / audit con timestamps relativos (`hace 3 min`)
- Settings tabs con switches, sliders, inputs con autosave fake

---

## Fase 5 — Toggle Demo Global ⭐ (FEATURE CLAVE)

En la esquina inferior derecha de TODA la app, un FAB (floating action button) o pill flotante:

```
🎬 MODO DEMO:  [Público]  [Usuario]  [Admin]
```

### Implementación

- Componente `<DemoModeSwitcher />` en el root layout
- Zustand store global para el modo activo
- Persiste el modo elegido en `localStorage` (default: `publico`)
- Al cambiar de modo, navigate al `/` o `/app` o `/admin` según corresponda
- Visible siempre EXCEPTO en `/sign-in` y `/sign-up`
- Animación spring suave al cambiar de modo (Framer Motion)
- En mobile, colapsa a un solo icono que abre menú

Este toggle es lo que más vende durante la presentación. **No lo escondas.**

---

## Fase 6 — Login fake pero con UX real

- `/sign-in` acepta CUALQUIER email + cualquier password (≥4 chars)
- Validación de formato email real
- Loading state de 800ms con spinner premium
- Si email contiene `admin@` o termina en `@demo.com` → redirect a `/admin`
- Si no → redirect a `/app`
- Si password contiene "fail" o "error" → muestra error elegante
- Botones de Google/Apple OAuth fake (loading + "login" igual)
- "Remember me" checkbox funcional (visualmente, no técnicamente)
- Link "Forgot password?" abre modal con flow simulado

---

## Fase 7 — Datos demo que cuentan historia

NO usar Lorem Ipsum, "Item 1", "John Doe". TODA la data debe ser plausible para el vertical detectado en Fase 0.

### Reglas para los datos

- **Nombres latinos:** Sofía, Mateo, Camila, Diego, Valentina, Sebastián, Isabella, Joaquín, Renata, Lucas
- **Empresas plausibles según vertical** (fintech: "Crédito Total", "Capital Express", "FinPro MX"; ecommerce: "Tienda del Sol", "Norte Boutique"; SaaS: "Tracksync", "Pulse Analytics")
- **Ciudades de México:** CDMX, Monterrey, Guadalajara, Querétaro, Mérida, Puebla, Tijuana
- **Cantidades realistas en MXN** ($1,250.00 no $123.45)
- **Fechas distribuidas en últimos 30-90 días**
- **Métricas con tendencias creíbles** (no todo `+50%`; mezclar `+12%`, `-3%`, `+28%`, estable)
- **Status variados** (active, pending, completed, cancelled — no todo "OK")

### Cantidades mínimas

- 50 usuarios/clientes ficticios
- 200 transacciones/eventos
- 30 productos/servicios o entidades del vertical
- 12 meses de datos históricos para charts

Todo en `/lib/demo-data/*.ts` con tipos estrictos.

---

## Fase 8 — Animaciones que venden

Framer Motion + Tailwind transitions. Incluir:

- Page transitions sutiles (fade + slide pequeño al cambiar ruta)
- Stagger en listas (cada item entra con delay 50ms)
- Hover micro-interactions en cards, buttons, links
- Number counters animados en KPIs (de 0 a valor en 1.5s al scroll)
- Skeleton loaders con shimmer effect
- Confetti al completar acciones importantes (`canvas-confetti`)
- Parallax sutil en hero (max 20px de desplazamiento)
- Cards con tilt 3D sutil al hover (`react-parallax-tilt`)

**NO usar animaciones que tarden >600ms ni que distraigan.** Premium = elegante, no exagerado.

---

## Fase 9 — PWA real

- `/public/manifest.json` con name, short_name, theme_color, background_color, icons (192, 512, maskable)
- Iconos generados desde el logo/favicon del input
- Service Worker con `next-pwa` o `serwist`:
  - Cache-first para fonts, íconos, logos
  - Network-first para páginas dinámicas
- Página `/offline` con branding
- Meta tags iOS standalone (apple-touch-icon, apple-mobile-web-app-capable)
- Instalable en mobile (Android Chrome + iOS Safari)

---

## Fase 10 — SEO + compartibilidad

- `next-seo` config global con title template, description, OG image
- `/opengraph-image.tsx` que genere imagen OG dinámica con branding
- `/twitter-image.tsx` idem para Twitter Cards
- Schema.org JSON-LD para Organization en root layout
- `robots.txt` y `sitemap.xml` dinámicos
- Lighthouse target: **≥95 performance, 100 SEO/a11y/best-practices**

---

## Fase 11 — Responsive mobile-first

- Diseñar primero para mobile (375px) y escalar
- Test específico en breakpoints: 375 / 768 / 1024 / 1440 / 1920
- Sidebar admin → drawer en mobile
- Tablas → cards en mobile
- Toda la app usable con una mano (botones primarios en zona alcanzable)

---

## Fase 12 — Cierre

Al terminar, generar y commitear:

1. `/README.md` con instrucciones del demo (qué credentials usar para entrar a cada modo)
2. `/STITCH_ANALYSIS.md` (el de Fase 0)
3. `/DEMO_SCRIPT.md` — guion de 5 minutos sugerido para presentar (qué páginas mostrar, en qué orden, qué destacar). Ver `references/presentation-script.md` para estructura.
4. Lighthouse scores documentados al final del README
5. Screenshots de las 3 vistas principales en `/docs/screenshots/`

Abrir PR draft contra `main` con título `"Demo PWA — [vertical detectado]"` y descripción listando los 3 modos.

Compartir al final:
- URL del preview de Vercel
- Link al PR
- Link al `DEMO_SCRIPT.md`

---

## NO hacer

- ❌ Lorem Ipsum
- ❌ placeholder.com (usar Unsplash API o SVGs custom)
- ❌ Botones que no hagan nada (todo responde con loading + toast)
- ❌ Paleta default de Tailwind sin extender (sin personalidad = sin venta)
- ❌ `console.warn` / `console.error` en producción
- ❌ TypeScript `any`
- ❌ Comentarios "TODO" excepto en decisiones documentadas
- ❌ Pedir confirmación a mitad del flujo

---

## Criterios de éxito

La demo se considera exitosa si:

- En **30 segundos** el prospecto entiende qué hace el producto
- En **2 minutos** navega entre los 3 modos con el toggle y se imagina usándolo
- Hay al menos **5 wow moments** visuales (animación, micro-interacción, dato sorpresa)
- El prospecto pregunta `"¿cuánto cuesta hacerlo de verdad?"`
- Se ve igual de premium en mobile que en desktop

---

## Archivos de referencia

- `references/presentation-script.md` — Estructura sugerida del DEMO_SCRIPT.md que generas
- `references/sales-tips.md` — Tips probados para cerrar durante la presentación
- `references/vertical-adaptations.md` — Cómo adaptar datos y copy a cada vertical de negocio común

Cargar bajo demanda según el vertical del cliente.
