# Estructura del DEMO_SCRIPT.md

Cuando se completa la demo, generar `/DEMO_SCRIPT.md` con un guion de 5 minutos para que Luis lo presente al prospecto. Estructura sugerida:

---

## Plantilla del guion

```markdown
# Guion de presentación — [Nombre del cliente]

## Apertura (30 segundos)
"[Cliente], esto que te voy a mostrar **no es una imagen estática**. Es la app
funcionando. Tres modos distintos: lo que ven tus clientes, lo que ven los
usuarios registrados, y lo que ves tú como dueño. Vamos a recorrer cada uno."

→ Abrir la URL en pantalla completa. Modo PÚBLICO por default.

## Modo Público (1 minuto)
**Mostrar:**
1. Hero animado — esperar 2 segundos a que las animaciones corran
2. Scroll lento a sección de features
3. Stats con counter animado
4. Sección de testimonios

**Decir:**
"Aquí entra alguien que escuchó de ti por primera vez. En 5 segundos sabe
qué haces. Mira las animaciones — todo eso impacta la decisión de compra."

## Modo Usuario (1.5 minutos)
**Cambio en vivo:** click en el FAB de modo demo → "Usuario"
→ Esto SOLO es el wow moment más grande. **Decir nada durante 3 segundos.**

**Mostrar:**
1. Dashboard del usuario
2. Una función principal completa (ej: hacer pedido, crear evento, etc.)
3. Notificaciones / historial

**Decir:**
"Lo que tu cliente ya registrado hace todos los días. Cada botón funciona,
cada animación está pulida. Esto baja la fricción y los regresa."

## Modo Admin (2 minutos) ← AQUÍ SE CIERRA
**Cambio en vivo:** click en el FAB → "Admin"

**Mostrar:**
1. KPIs grandes con tendencias
2. Tabla de usuarios con filtros — clickear en uno y mostrar drawer de detalle
3. Reporte con gráfica
4. Configuración rápida

**Decir:**
"Esto es lo que vas a usar tú o tu equipo. Sabes en tiempo real cuánto facturas,
quién está activo, qué se vendió. Sin esto estarías ciego."

## PWA + Mobile (30 segundos)
1. Sacar el celular
2. Mostrar `eternime.org` (o el dominio del demo)
3. Botón "Agregar a pantalla de inicio" → instalar
4. Mostrar que funciona offline

**Decir:**
"Tu cliente lo instala como si fuera una app nativa. Sin pasar por App Store.
Sin actualizaciones manuales."

## Cierre (30 segundos)
"Lo que viste aquí es demo. **La versión real**, con tu marca, tus colores,
tu logo, integrada con [proceso de pagos / CRM / WhatsApp / lo que necesite],
deployment en tu propio dominio, código fuente tuyo, en **[N] semanas**.
Inversión: **$[Y]**.
¿Empezamos?"

→ Silencio. Dejar que el cliente hable primero.
```

---

## Cosas que el guion NUNCA debe omitir

1. **El momento "cambio de modo en vivo"** — es el más memorable
2. **Mostrar mobile** — diferenciador real
3. **Decir precio al final** — sin precio, no hay cierre
4. **Silencio final** — el primero que habla pierde la negociación

## Personalizaciones según vertical

- **Fintech:** enfatizar seguridad, auditoría, cumplimiento
- **Ecommerce:** enfatizar carrito, checkout, tracking de pedidos
- **SaaS:** enfatizar onboarding, automatización, integraciones
- **Marketplace:** enfatizar buscador, ratings, comisiones
- **Restaurante / servicio local:** enfatizar reservas, WhatsApp, geolocalización

## Datos que Code debe inyectar en el guion

Al generar `/DEMO_SCRIPT.md`, completar:
- `[Cliente]` → nombre placeholder o si Luis lo dio
- `[N] semanas` → estimar según complejidad (8-16 típico)
- `[Y]` → dejar como `_____` para que Luis llene según su pricing
- `[proceso de pagos / CRM / ...]` → listar 3-4 integraciones plausibles del vertical
