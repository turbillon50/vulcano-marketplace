# Las 7 lentes — cómo se mira una app antes, durante y después de construirla

Origen: carrusel de @alpacka.ai (7 prompts "actúa como…" para sitios de lujo) que Luis mandó el 24-sep-2026
pidiendo revisarlos para la fábrica. Se adaptaron: los originales son genéricos (sin entradas, sin criterio de
aceptación, sin medición, y el primero le pide al agente inventar la identidad visual, que aquí es ley de Luis).
Lo que sí aportan es el **orden de las preguntas**: qué se mira y cuándo. Aquí cada lente tiene qué recibe, qué
entrega y cómo se comprueba. La salida de una lente nunca es un ensayo: son renglones para `LISTA-*.md` con
criterio medible, o texto que va directo al código.

Reglas que mandan sobre las 7: el diseño de Luis es la ley (lente 1 no inventa marca), sin datos inventados
(lente 4 no inventa testimonios ni cifras), solo paleta de marca, medir antes de afirmar.

| # | Lente | Cuándo | Entrega |
|---|---|---|---|
| 1 | El plano | Arranque de app nueva, o tras `RESCATE.md` | Bloques del brief en orden de construcción |
| 2 | Lo primero que ven | Antes de tocar la home/landing | Hero: título, subtítulo, evidencia, CTA; 3 variantes de copy |
| 3 | Cómo se mueve | Antes del primer componente animado | Sistema de movimiento en tokens + lista de "nunca se mueve" |
| 4 | La redacción | Antes de escribir textos de pantalla | Copy por pantalla en tabla, con la objeción que responde |
| 5 | Plan de construcción | Después de 1–4, antes de programar | Componentes, carpetas, breakpoints, carga de imágenes/fuentes |
| 6 | Auditoría de conversión | Con la app en producción, antes de decir "lista" | Fricciones ordenadas por impacto, 3 cambios, métrica que lo prueba |
| 7 | Plan de lanzamiento | Al cerrar el loop | 30 días: checklist, revisión semanal, 3 experimentos, criterio de parar |

## Lente 1 · El plano
**Entradas obligatorias:** la referencia visual de Luis (imágenes/plantilla) o la app existente + `RESCATE.md`;
público (quién abre el link y desde dónde: WhatsApp, Instagram, tienda); 3 apps con las que se va a comparar;
memorias del proyecto en el Brain.
**Prompt (para el agente):**
> Con la referencia de Luis como ley (no la rediseñes), describe en una página: qué debe sentir la persona en los
> primeros 3 segundos (una frase), el orden de pantallas de la primera visita sin cuenta, la narrativa al bajar
> (qué se entiende en cada tercio de pantalla), y el orden exacto de construcción en bloques con criterio de
> aceptación cada uno. Compara con las 3 apps dadas solo en lo que ellas hacen mejor y que aquí se va a superar,
> con la medida (tiempo, toques, pantallas).
**Salida:** bloques para `BRIEF-*.md` y renglones en `LISTA.md` §Primera impresión. Nada de identidad visual nueva.

## Lente 2 · Lo primero que ven
**Entradas:** de dónde viene la persona (el link que abrió y el mensaje que lo acompañaba), la promesa real del
producto (una frase de Luis), qué evidencia real existe (número de clientes, apps en producción, certificación),
la acción que debe tomar en menos de 10 segundos.
**Prompt:**
> Escribe el hero para 375×667 y 1440×900: título (≤ 8 palabras), subtítulo (≤ 20), la evidencia visible sin
> scroll (solo la que existe), botón primario y secundario con su destino. Da 3 variantes de título+subtítulo
> para prueba A/B, cada una con la hipótesis de a quién le habla. Regla: título, subtítulo y CTA visibles sin
> scroll en 375×667 (MUST §15).
**Salida:** el hero en código + las 3 variantes en `REPORTE-*.md`. Se mide con la lente 6 cuando haya analítica.

## Lente 3 · Cómo se mueve
**Entradas:** personalidad de la marca en 3 adjetivos (de Luis o del Brain), presupuesto de rendimiento
(LCP ≤ 2.5 s, TBT ≤ 200 ms en 4G simulada), `prefers-reduced-motion` obligatorio.
**Prompt:**
> Define el sistema de movimiento en tokens CSS: 3 duraciones (rápida/normal/lenta), 2 curvas, qué anima la
> entrada de una pantalla, qué hace un botón al tocarlo, qué pasa al cambiar de pestaña, y la lista explícita de
> lo que NUNCA se mueve (texto que se lee, precios, formularios, tab bar). Todo scroll programático dentro de su
> contenedor. Con reduced-motion: solo opacidad.
**Salida:** `motion.css` con los tokens + la lista de "nunca se mueve" en `LISTA.md` §Producto. Criterio: 0 CLS
por animación (MUST §A5) y ninguna animación > 400 ms en interacción.

## Lente 4 · La redacción
**Entradas:** nivel de conocimiento del visitante al llegar (no sabe qué es / ya lo vio / ya lo usa), la objeción
que aparece en cada pantalla, las palabras exactas que usan los clientes de Luis (de sus chats de WhatsApp o del
Brain, nunca inventadas), pruebas reales disponibles.
**Prompt:**
> Para cada pantalla de la primera visita y del registro, una fila: pantalla · qué sabe ya la persona · objeción
> que le surge · texto (título, cuerpo ≤ 2 frases, microtexto de botón/campo) · qué evidencia real lo respalda o
> "sin evidencia, se omite". Español de México, tú, sin anglicismos que Luis no use, sin signos de exclamación
> de relleno. Términos de Luis se respetan (ej. "Profesionistas").
**Salida:** tabla en `COPY.md` y el texto directo en los componentes. Prohibido: testimonios, cifras o logos que
no existan.

## Lente 5 · Plan de construcción
**Entradas:** salidas de 1–4, el repo, `pwa-agencia-premium` §1–§3 para carga/ícono.
**Prompt:**
> Lista los componentes que se repiten (con sus variantes), la estructura de carpetas, los breakpoints (375/390/
> 430 móvil; ≥ 1024 escritorio con composición propia, no estirada), la estrategia de imágenes (next/image,
> width/height siempre, `priority` solo en la primera visible, `sizes` reales, formatos y pesos máximos) y de
> fuentes (máximo 3 pesos, `display: swap`, subset), y la lista de verificación previa a subir (MUST-500
> secciones 1, 4, 5 y 8 como mínimo).
**Salida:** bloques del brief con criterio; el plan de imágenes/fuentes entra a `LISTA.md` §Producto.

## Lente 6 · Auditoría de conversión
**Entradas:** la app en producción, capturas WebKit sin sesión 390 y 1440, analítica si existe (embudo:
visita → registro iniciado → terminado → acción principal), `MUST-500-<app>.md`.
**Prompt:**
> Recorre como desconocido desde el link hasta la acción principal (publicar / contactar / comprar). Para cada
> paso: qué duda queda sin resolver antes de tocar, qué señal de confianza falta, cuántos toques y segundos
> cuesta, y si hay un muro (registro forzado, invitación fija, contador que vende vacío). Ordena las fricciones
> por impacto × facilidad, elige los 3 cambios de mayor impacto, di el experimento en orden y la métrica exacta
> que demuestra que funcionó (con el número de hoy y la meta).
**Salida:** renglones en `LISTA.md` con evidencia y en `REPORTE-*.md` la tabla de fricciones. Momentum 24-sep:
esta lente fue la que sacó el muro fijo del perfil, el "0 inversionistas" y los 8–12 s de carga.

## Lente 7 · Plan de lanzamiento (30 días)
**Entradas:** fuentes de tráfico que Luis controla (WhatsApp, LinkedIn, Instagram, clientes actuales, aliados),
analítica viva, quién contesta soporte.
**Prompt:**
> Escribe el plan de los primeros 30 días: checklist del día 0 (analítica midiendo, soporte contestando, backups,
> alertas de error, cuenta de prueba), qué pantallas se vigilan a diario la primera semana, cómo se recoge
> feedback a bajo costo (3 preguntas por WhatsApp a los primeros 10 usuarios), las 5 métricas que se miden
> aunque haya poco tráfico (visitas, registro terminado, acción principal, retorno a 7 días, tiempo hasta la
> primera acción), el calendario de revisión semanal, 3 experimentos en orden (cada uno con hipótesis, cambio,
> métrica, duración) y el criterio para dejar de cambiar cosas (dos semanas seguidas sin mejora en la métrica
> principal → se congela y se pasa a captación).
**Salida:** `LANZAMIENTO.md` en el repo + los experimentos como bloques futuros del brief.

## Cómo entran en la fábrica
- `fabrica.sh` pone en el brief: **nuevo** → lentes 1, 2, 3, 4, 5 antes de programar; 6 y 7 al cerrar.
  **rescate** → `RESCATE.md`, luego 6 (sobre lo que hay), luego 1–5 solo sobre lo que se decidió rehacer, 7 al cerrar.
- Cada lente termina en renglones de `LISTA.md` con criterio medible. Una lente que solo produjo prosa no cuenta.
- Las lentes 2, 4 y 6 se repiten cuando hay analítica de 30 días: con números reales, no con opinión.
