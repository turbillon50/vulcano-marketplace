---
name: demo-screens
description: Crear demos de pantallas navegables SIN integraciones reales. Solo flujos visuales con datos hardcodeados, navegación entre vistas y toggle de modos (público/usuario/admin). ACTIVAR cuando el usuario diga "demo", "pantallas", "flujo", "mockup funcional", "para mostrar", "demo rápida", "que se vea el flujo", "screens", o cualquier variante que implique mostrar cómo se vería una app SIN necesidad de backend, APIs, auth real, base de datos ni servicios externos. También activar cuando detectes que Claude Code está intentando integrar servicios reales (Clerk, Stripe, Neon, APIs externas) en lo que debería ser una demo visual. Esta skill tiene PRIORIDAD sobre demo-pwa-builder cuando el contexto es "mostrar pantallas" y no "construir demo completa con PWA". Si hay duda entre esta skill y demo-pwa-builder, usar ESTA — es más rápida y tiene mayor tasa de éxito en una sola corrida.
---

# Demo Screens — Pantallas que venden, sin integraciones

Esta skill produce demos navegables de alta calidad visual en UNA sola corrida. La diferencia con `demo-pwa-builder` es que aquí NO se integra nada real — todo es visual, hardcodeado y funcional en pantalla.

---

## Filosofía

> **Si no se ve en pantalla, no existe en esta skill.**

No auth real. No API calls. No base de datos. No service workers. No webhooks. No env vars.
Solo pantallas bonitas con datos fake que se navegan como app real.

---

## Cuándo usar esta skill vs demo-pwa-builder

| Señal del usuario | Skill correcta |
|---|---|
| "hazme una demo", "quiero mostrar las pantallas" | ✅ **demo-screens** |
| "demo para el cliente", "que se vea el flujo" | ✅ **demo-screens** |
| "mockup funcional", "prototipo navegable" | ✅ **demo-screens** |
| "demo completa con PWA instalable y auth" | demo-pwa-builder |
| "quiero que funcione el login con Clerk" | demo-pwa-builder |
| "conecta Stripe para pagos reales" | demo-pwa-builder |

**Regla de oro:** Si no mencionó explícitamente integraciones reales → usar esta skill.

---

## Reglas NO negociables

### LO QUE SÍ HACE
- ✅ Pantallas navegables entre rutas
- ✅ Toggle flotante para cambiar entre modos (público / usuario / admin)
- ✅ Datos hardcodeados inline (nombres latinos, montos en MXN, fechas recientes)
- ✅ Navegación con Next.js App Router (o React Router si es más simple)
- ✅ Tailwind + shadcn/ui para verse profesional
- ✅ Tablas, cards, dashboards con datos estáticos
- ✅ Modales y drawers que abren/cierran
- ✅ Responsive básico (mobile + desktop)
- ✅ Dark/light mode toggle

### LO QUE NO HACE (NUNCA)
- ❌ **NO instalar ni configurar Clerk, Auth.js, NextAuth ni ningún auth**
- ❌ **NO conectar a Neon, Supabase, Firebase ni ninguna base de datos**
- ❌ **NO llamar APIs externas (Stripe, Reloadly, Duffel, Viator, etc.)**
- ❌ **NO configurar webhooks**
- ❌ **NO crear archivos .env ni env vars**
- ❌ **NO instalar Prisma, Drizzle ni ningún ORM**
- ❌ **NO crear API routes que llamen servicios externos**
- ❌ **NO service workers ni PWA manifest**
- ❌ **NO SEO dinámico ni OG image generation**
- ❌ **NO Lighthouse optimization**
- ❌ **NO pedir confirmación a mitad del proceso**

Si Claude Code siente la tentación de "preparar la integración para después", **NO LO HAGA**. Eso es trabajo de otra fase, otra skill, otro día.

---

## Stack obligatorio (mínimo viable)

```
Next.js 15+ App Router
TypeScript (strict, zero `any`)
Tailwind CSS v4
shadcn/ui
Lucide React (iconos)
Framer Motion (animaciones sutiles, OPCIONALES — no bloquear la entrega por esto)
```

**NO instalar más de esto.** Cada dependencia extra es un punto de fallo. Si recharts no es crítico, usar barras CSS simples.

---

## Estructura de archivos

```
src/
├── app/
│   ├── layout.tsx          ← Root layout con DemoModeSwitcher
│   ├── page.tsx            ← Landing / home público
│   ├── como-funciona/
│   ├── precios/
│   ├── contacto/
│   ├── sign-in/            ← Form fake (acepta cualquier cosa)
│   ├── sign-up/            ← Form fake
│   ├── app/                ← Vistas de USUARIO
│   │   ├── page.tsx        ← Dashboard usuario
│   │   ├── [feature-1]/
│   │   ├── [feature-2]/
│   │   └── perfil/
│   └── admin/              ← Vistas de ADMIN
│       ├── page.tsx        ← Dashboard admin con KPIs
│       ├── usuarios/
│       ├── [entidad-1]/
│       ├── reportes/
│       └── configuracion/
├── components/
│   ├── demo-mode-switcher.tsx   ← Toggle flotante ⭐
│   ├── layouts/
│   │   ├── public-layout.tsx
│   │   ├── app-layout.tsx
│   │   └── admin-layout.tsx
│   └── ui/                 ← shadcn components
├── lib/
│   ├── demo-data.ts        ← TODOS los datos fake en UN archivo
│   └── demo-store.ts       ← Zustand store para modo activo
└── ...
```

---

## El Toggle Demo (COMPONENTE CLAVE)

Pill flotante en esquina inferior derecha de TODA la app:

```
🎬 [Público] [Usuario] [Admin]
```

- Siempre visible excepto en sign-in/sign-up
- Al cambiar modo → navega a `/` o `/app` o `/admin`
- Estado en Zustand + localStorage
- En mobile: colapsado a un icono que abre menú

**Este componente es lo primero que se construye y lo último que se quita.**

---

## Login fake

- `/sign-in` acepta CUALQUIER email + password (≥1 char)
- Si email contiene "admin" → redirect `/admin`
- Si no → redirect `/app`
- Loading de 500ms con spinner
- Botones de Google/Apple OAuth que hacen lo mismo
- **NO instalar Clerk, NextAuth ni nada. Es un form con redirect hardcodeado.**

---

## Datos demo

Todo en `/lib/demo-data.ts`. UN solo archivo. Exportar arrays/objetos tipados.

**Reglas:**
- Nombres latinos: Sofía, Mateo, Camila, Diego, Valentina
- Ciudades MX: CDMX, Monterrey, Guadalajara, Querétaro, Mérida
- Montos en MXN realistas ($1,250.00 no $123.45)
- Fechas en últimos 30 días
- Status variados (activo, pendiente, completado, cancelado)
- Mínimo: 10-15 registros por entidad (suficiente para llenar tablas, no 50+)

---

## Fases de ejecución (en orden estricto)

### Fase 1 — Setup (5 min)
- Crear proyecto Next.js o usar el existente
- Instalar Tailwind + shadcn/ui + Lucide
- Crear `demo-data.ts` con datos del vertical
- Crear `demo-store.ts` con Zustand

### Fase 2 — Toggle + Layouts (10 min)
- `DemoModeSwitcher` flotante
- 3 layouts (público, usuario, admin)
- Navegación básica entre modos

### Fase 3 — Pantallas públicas (10 min)
- Home con hero
- Página de precios (3 planes)
- Sign-in / sign-up fake

### Fase 4 — Pantallas de usuario (10 min)
- Dashboard con cards de resumen
- 1-2 features principales del producto
- Perfil básico

### Fase 5 — Pantallas de admin (10 min)
- Dashboard con KPIs grandes
- Tabla de usuarios/entidades con paginación visual
- Página de configuración con tabs

### Fase 6 — Cierre (5 min)
- Verificar que el toggle funciona en todos los modos
- Verificar responsive básico
- Commit + push
- Reportar URL de preview

**Tiempo total estimado: ~50 minutos de Claude Code. NO 3 horas.**

---

## Qué entregar al final

1. URL de preview de Vercel (o localhost)
2. Confirmación de que los 3 modos navegan correctamente
3. Lista de pantallas creadas

**NO generar:** DEMO_SCRIPT.md, STITCH_ANALYSIS.md, screenshots, Lighthouse scores, ni documentación extra. Eso es para `demo-pwa-builder`.

---

## Manejo de errores comunes de Claude Code

### "Necesito configurar Clerk para el auth"
→ **NO.** El login es un form fake con redirect. No hay auth real.

### "Voy a crear las API routes para conectar con [servicio]"
→ **NO.** No hay API routes que llamen servicios externos. Los datos están en `demo-data.ts`.

### "Instalo Prisma/Drizzle para el schema de la base de datos"
→ **NO.** No hay base de datos. Todo es hardcoded.

### "Configuro el webhook de Stripe para..."
→ **NO.** No hay webhooks. Los botones de pago muestran un toast de "¡Pago simulado exitoso!".

### "Necesito las env vars de..."
→ **NO.** No hay env vars. Si algo necesita una key para compilar, es que estás integrando algo real y no deberías.

### "Voy a preparar la estructura para que después sea fácil conectar..."
→ **NO.** No preparar nada para después. Solo pantallas de hoy. La integración real es otro proyecto, otro branch, otra skill.

---

## Criterios de éxito

La demo se considera exitosa si:

- ✅ Los 3 modos (público/usuario/admin) navegan sin errores
- ✅ El toggle flotante funciona en todas las páginas
- ✅ Las pantallas tienen datos plausibles (no Lorem Ipsum, no "Item 1")
- ✅ Se ve profesional en desktop y aceptable en mobile
- ✅ Se completó en UNA corrida sin pedir confirmaciones
- ✅ **No se instaló NI UNA integración externa**
