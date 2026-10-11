---
name: calca-tokens
description: >
  Estándar numérico OBLIGATORIO de UI para la fábrica VForge: medidas de entrada
  (botones, espaciados, radios), roles de color, escala tipográfica, microinteracciones,
  tiempos, desplazamientos y sombras. Incluye el instrumento calca.py para medir
  referencias y comparar captura-vs-referencia. ACTIVAR antes de construir o revisar
  cualquier pantalla; al crear tokens.css; cuando Luis diga "calca", "referencia",
  "mide la imagen", "tokens", "estándar"; y en toda entrega de UI de los proyectos
  con dinero (HappyToc, V&LIVING, Zuxen, Ruta 618, Knoxia, Tratto, M.IA).
triggers:
  - calca
  - tokens
  - medidas de UI
  - estándar de diseño
  - microinteracciones
  - tiempos de animación
---

# calca-tokens — la rejilla de La Calca

**Ley primero:** los VALORES concretos (hex, fuente, marca) vienen de la REFERENCIA aprobada por Luis — nunca de memoria. Este estándar define los ROLES, ESCALAS y RANGOS que llenas con esos valores. Sin referencia no se dibuja: se diseña con Luis primero.

## El paquete obligatorio por pantalla (paridad)

| Archivo | Qué es |
|---|---|
| `referencia.png` | Imagen aprobada por Luis (desktop 1440, móvil 390 si aplica) |
| `tokens.css` | Custom properties medidas de la referencia (usa `calca.py medir`) |
| `PROMESAS.md` | Cada elemento interactivo → promesa → consecuencia → prueba |
| `capturas/` | Capturas renderizadas + resultado de `calca.py comparar` |

## 1. Espaciado (base 4px — solo estos valores)

`--space-1:4px · --space-2:8px · --space-3:12px · --space-4:16px · --space-5:24px · --space-6:32px · --space-7:48px · --space-8:64px · --space-9:96px`

- Padding interno de tarjetas/paneles: `--space-5` (24px). Entre secciones: `--space-7`/`--space-8`.
- Gaps en listas/filas: `--space-3`. Gap icono-texto: `--space-2`.
- Prohibido: valores fuera de la escala (los 9-24px mezclados de Knoxia eran el síntoma).

## 2. Radios y bordes

`--radius-sm:8px · --radius-md:12px · --radius-lg:16px · --radius-xl:24px · --radius-pill:999px`

- Inputs y botones: `--radius-md`. Tarjetas: `--radius-lg`. Modales/sheets: `--radius-xl`. CTA principal puede ser pill.
- Borde: `1px solid var(--color-border)`. Focus ring: `2px` accent con `offset 2px`.

## 3. Botones (dimensiones de entrada)

| Tamaño | Altura | Padding-X | Fuente | Uso |
|---|---|---|---|---|
| sm | 36px | 16px | 13px/600 | Dense (tablas, toolbars) |
| md | 44px | 20px | 14-15px/600 | Default (44px = touch mínimo) |
| lg | 52px | 24px | 16px/600 | CTA principal / móvil |

- Estados: hover = `filter:brightness(1.06)` o mezcla 8% hacia blanco; **active = `scale(0.98)`**; disabled = `opacity:.45` + sin eventos; focus-visible = ring.
- Iconos dentro de botón: 18-20px, gap `--space-2`. Nunca botón < 44px de zona táctil en móvil (aunque visualmente sea 36).

## 4. Color (roles fijos, valores de la referencia)

`--color-bg · --color-surface · --color-surface-2 · --color-border · --color-border-strong · --color-text · --color-text-2 · --color-text-muted · --color-accent · --color-accent-hover · --color-on-accent · --color-success · --color-warning · --color-danger`

- **Un solo acento dominante + máximo un secundario.** (Knoxia llegó a 4 paletas peleándose: teal + morado + verde-gris + morado 2.)
- Contraste AA: texto 4.5:1, texto grande/UI 3:1. Verificar con el sample de `medir`.
- Estados derivados: hover = mezcla 8% blanco (dark) o 8% negro (light); active-border = accent al 60%.

## 5. Tipografía (escala cerrada)

| Token | Tamaño/línea | Peso | Uso |
|---|---|---|---|
| `--fs-caption` | 12px/1.3 | 500 | Metadatos, timestamps (mínimo absoluto) |
| `--fs-body-sm` | 13px/1.5 | 400 | Secondary UI |
| `--fs-body` | 14-15px/1.5 | 400 | Cuerpo, chat |
| `--fs-body-lg` | 16px/1.6 | 400 | Lectura larga |
| `--fs-h3` | 18-20px/1.3 | 600 | Títulos de tarjeta |
| `--fs-h2` | 24px/1.25 | 650 | Títulos de sección |
| `--fs-h1` | 32-48px/1.1 | 700 | Display/hero |

- Labels uppercase: 11-12px/600 + `letter-spacing:.04em`. **Prohibido < 11px** (los labels de 8-10px de Knoxia se rechazaron).
- La fuente se CARGA de verdad (`next/font` o @font-face). Si está en el stack pero no se carga, es Segoe/Arial disfrazada — rechazo seguro.

## 6. Motion (tiempos, easings, desplazamientos)

| Token | Valor | Uso |
|---|---|---|
| `--dur-instant` | 80ms | Feedback de estado (pressed, toggle) |
| `--dur-fast` | 150ms | Hover, color, opacidad |
| `--dur-base` | 220ms | Entradas, dropdowns, tooltips |
| `--dur-slow` | 320ms | Modales, sheets, drawers |
| `--dur-page` | 450ms | Transición de vista (techo absoluto) |
| `--ease-out` | `cubic-bezier(0.16,1,0.3,1)` | Entradas (default) |
| `--ease-in-out` | `cubic-bezier(0.65,0,0.35,1)` | Movimientos de posición |
| `--ease-spring` | `cubic-bezier(0.34,1.56,0.64,1)` | Solo elements pequeños y celebratorios |

Desplazamientos estándar: hover-lift `translateY(-2px)` + `--shadow-md`; entrada de elemento `translateY(8-12px)+fade` a `--dur-base`; modal `scale(.96→1)+fade`; drawer slide = su propio ancho; toast desde abajo con `--dur-slow`.

Microinteracciones mínimas de producto premium: botón press `scale(.98)`; input focus = border accent + ring `3px accent/20%`; skeleton pulse 1.5s `ease-in-out` infinito; streaming de chat = fade-in por chunk 120ms (única excepción al techo).

**`prefers-reduced-motion: reduce`** → todo a opacity-only o 0ms. Obligatorio.

## 7. Sombras y cristal

`--shadow-sm: 0 1px 2px rgb(0 0 0/.06) · --shadow-md: 0 4px 12px rgb(0 0 0/.08) · --shadow-lg: 0 12px 32px rgb(0 0 0/.12)`

Cristal: `background:color-mix(in srgb, var(--color-surface) 65-75%, transparent)` + `backdrop-filter:blur(12-20px)` + borde `1px` blanco/negro al 8-12% según tema. Máximo 2 superficies de cristal visibles por pantalla (la "fiesta visual" se rechazó en Knoxia).

## 8. Z-index (escala cerrada)

`--z-base:0 · --z-raised:10 · --z-dropdown:100 · --z-sticky:200 · --z-overlay:300 · --z-modal:400 · --z-toast:500`

## 9. HTML pesado, JS quirúrgico

Estructura y piel en HTML de servidor. JavaScript solo en islas de funcionalidad real (chat, sesiones, formularios, upload). Prohibido cargar librerías (grafos, carruseles) para vistas que nadie enlaza.

## 10. El instrumento: calca.py

```bash
# Extraer tokens sugeridos de la referencia (paleta por roles + métricas)
python3 calca.py medir referencia.png

# La calca: captura vs referencia (mismo viewport!)
python3 calca.py comparar referencia.png captura.png --out /tmp/calca
#   → overlay50.png (la hoja encima del dibujo), difference.png,
#     % de píxeles distintos y las 3 peores regiones (dónde corregir)
```

Loop obligatorio antes de mostrar: render → captura (mismo viewport que la referencia) → `comparar` → corregir las regiones señaladas → repetir hasta diff bajo y veredicto visual humano/judge. El % informa; el ojo decide. Compilar NO equivale a calcar.

## Prohibiciones que ya costaron (11-oct: Knoxia/Tratto)

1. Dibujar de memoria sin referencia debajo.
2. Parchar encima de un rechazo en vez de reemplazar.
3. Fuente declarada y no cargada. Labels < 11px. Más de 1 acento dominante.
4. Animaciones > 450ms. Librerías pesadas para vistas huérfanas.
5. Servir ramas no aprobadas o mezclar UI sin aprobar en release.
