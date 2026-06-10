---
name: design-library
description: Biblioteca de Tipos de Diseno de la FABRICA. Catalogo de estilos para que NO todas las apps salgan iguales — vibes (obsidian/dark premium, calido-hogareno, racing rojo/negro, corporativo limpio, etc.), efectos (carruseles cover-flow, parallax, vinilo girando, glassmorphism, pinch-zoom, pop-ups suaves), tipografias y combos segun el giro. Elige UNA "ficha de diseno" por proyecto. Incluye los estandares v3 (responsive real, no-lucide, flotantes no tapan nav). Se apoya en clone-vibe y theme-factory. ACTIVAR cuando el usuario diga "diseno", "estilo", "vibe", "que se vea", "look", "tema", "como lo vestimos", "ficha de diseno", "design-library", "que no se vea igual", "efectos", "carrusel", "parallax", o despues de product-standard cuando ya hay esqueleto y toca vestirlo. TERCER modulo del pipeline (context-min -> product-standard -> design-library -> total-supervision).
version: 1.0
agents: [Vulcano]
triggers: [diseno, estilo, vibe, que se vea, look, tema, como lo vestimos, ficha de diseno, design-library, que no se vea igual, efectos, carrusel, parallax]
---

# design-library — Biblioteca de Tipos de Diseno

Tercer eslabon de la FABRICA. Toma el `{contexto + esqueleto}` y le elige una **ficha de diseno** del catalogo para que cada producto tenga personalidad propia. **Nada de plantillas clonadas que se ven todas iguales.**

> Regla de oro: **cada giro, su vibe.** Una funeraria no se viste como un racing shop. El catalogo evita la monotonia.

Se apoya en:
- **clone-vibe** -> clonar el vibe visual de una URL de referencia (neon.tech, replit, linear, vercel, stripe).
- **theme-factory** -> aplicar colores/tipografia/tema al artefacto.

---

## CATALOGO DE VIBES

| Vibe | Cuando (giro) | Paleta tipica | Tipografia |
|---|---|---|---|
| **Obsidian / dark premium** | SaaS, marketplaces creativos, fintech, legado digital | negros/grises + acento neon | Geist / Inter, grotesk |
| **Calido-hogareno** | spa, salud, comunidad, cuidado, ONG | cremas, terracota, verde salvia | serif suave + sans humanista |
| **Racing rojo/negro** | autos, delivery rapido, deportes, gaming | rojo/negro/blanco, alto contraste | condensed bold + mono |
| **Corporativo limpio** | B2B, despachos, seguros, consultoria | azul/gris/blanco, mucho aire | Inter/Helvetica neutra |
| **Retail vibrante** | e-commerce, moda, gadgets | acentos saturados sobre blanco | display + sans legible |
| **Editorial/lujo** | boutique, joyeria, hoteleria | negro/oro/marfil | serif alta + tracking amplio |

(El `vibe_sugerido` viene de context-min; aqui se confirma o cambia segun logo y audiencia.)

---

## CATALOGO DE EFECTOS

| Efecto | Para que sirve | Cuidado |
|---|---|---|
| **Carrusel cover-flow** | portafolios, galerias, productos destacados | touch real en movil, no romper en 390px |
| **Parallax** | hero narrativo, storytelling | suave, no marear, respetar reduce-motion |
| **Vinilo girando** | musica, audio, legado con voz (ElevenLabs) | pausa cuando no se ve |
| **Glassmorphism** | overlays premium, paneles flotantes | contraste de texto legible |
| **Pinch-zoom** | mapas, fotos, catalogos detallados | no bloquear scroll de pagina |
| **Pop-ups suaves** | confirmaciones, retro del admin al usuario | no modal-trap, cerrable, accesible |

---

## LA FICHA DE DISENO (salida)

Se elige UNA por proyecto y se guarda:
```json
{
  "project_id": "andromeda",
  "vibe": "obsidian/dark premium",
  "paleta": {"primario":"#6D28D9","fondo":"#0B0B12","acento":"#22D3EE","texto":"#E5E7EB"},
  "tipografia": {"titulos":"Geist","cuerpo":"Inter"},
  "efectos": ["carrusel cover-flow", "pop-ups suaves", "glassmorphism"],
  "referencia_clone_vibe": "linear.app",
  "v3": true
}
```

---

## ESTANDARES v3 (obligatorios, no negociables)

- **Responsive REAL** en 390 (movil), 768 (tablet), 1440 (escritorio). No "se ve bien en una sola medida".
- **No-lucide**: no depender de lucide-react para iconos criticos (rompe en algunos builds). Usar SVG inline o set verificado.
- **Flotantes no tapan nav**: el toggle de modos y botones flotantes NUNCA cubren la navegacion ni el contenido clave. Posicion segura + safe-area.
- Imagenes con fallback (no rotas).
- Carruseles con touch real en movil.

---

## PROCEDIMIENTO

1. Leer `{contexto + esqueleto}` y el `vibe_sugerido`.
2. Confirmar/elegir **vibe** del catalogo segun giro + logo + audiencia.
3. Elegir **efectos** que aporten (sin saturar) y **tipografia**.
4. Si hay URL de referencia -> invocar **clone-vibe**; aplicar tema con **theme-factory**.
5. Emitir la **ficha de diseno** (JSON arriba) y guardarla:
   ```
   UPDATE projects SET phase='diseno', next_step='total-supervision', last_agent='design-library', updated_at=now() WHERE id='andromeda'
   ```
6. Registrar leccion si el vibe nuevo funciono bien (win) en `lessons`.

---

## HANDOFF / PIPELINE

```
product-standard -> [design-library: + ficha de diseno + v3] -> total-supervision
```

- **Consume** contexto + esqueleto de `product-standard`.
- **Produce** la ficha de diseno y marca `next_step='total-supervision'`.
- **Entrega** a `total-supervision`, que valida que los estandares v3 (responsive 390/768/1440, no-lucide, flotantes) se cumplan de verdad.
