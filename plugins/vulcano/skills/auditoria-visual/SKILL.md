---
name: auditoria-visual
description: Auditoria visual comparativa de paginas web. Navega una pagina y la "ve" de verdad — captura screenshot, extrae los tokens reales (paleta de colores, tipografias, pesos, tamanos, contraste WCAG, espaciados, radios, sombras) y mide los tiempos de carga (TTFB, DOMContentLoaded, load, peso total, # de requests). Luego la compara LADO A LADO contra una o varias paginas de referencia y emite veredicto + mejoras concretas priorizadas (que copiar de la referencia). ACTIVAR cuando Luis diga compara esta pagina con, auditoria visual, como se ve vs, drena el estilo de, referencia visual, que le falta a mi landing vs, contraste, tiempos de carga, side-by-side, ver como se compara con neon/linear/vercel/stripe, ojos con vision real. Usa las herramientas de Claude in Chrome (navigate, computer/screenshot, read_page, javascript_tool, read_network_requests). NO inventa valores: todo sale de la pagina real via JS. Si Chrome no esta conectado, pide instalar la extension.
---
# Auditoria Visual Comparativa (ojos con vision real)

## Objetivo
Comparar una pagina OBJETIVO (normalmente de Luis) contra 1+ paginas de REFERENCIA (neon.tech, linear.app, stripe.com, vercel.com u otras), con datos REALES, no impresiones.

## Pasos (repetir 1-4 por cada pagina; luego 5-6)
1. tabs_create_mcp + navigate a la URL. Espera a que cargue (wait ~2-3s si hay splash/animaciones).
2. computer screenshot (para VER: layout, jerarquia, aire, densidad, "vibe"). read_page si necesitas el arbol.
3. javascript_tool: corre el snippet `extract-tokens.js` (esta en esta carpeta) -> devuelve JSON con:
   - colores dominantes (bg, texto, acentos) con hex y % de uso
   - tipografias (font-family, weights, tamanos, line-height del h1/body/botones)
   - contraste WCAG de los pares texto/fondo clave (ratio + AA/AAA pass/fail)
   - espaciados/gaps mas usados, border-radius, box-shadows
   - conteo de elementos, ancho de contenido (max-width del contenedor)
4. read_network_requests (o performance.timing via javascript_tool): TTFB, DOMContentLoaded, load, peso total (KB), # requests, # de imagenes/fuentes.
5. COMPARA lado a lado en una tabla: por cada dimension (paleta, tipografia, contraste, ritmo/espaciado, tiempos, peso) -> Objetivo vs Referencia(s), marcando quien gana y por que.
6. VEREDICTO + mejoras priorizadas: lista concreta de "que copiar/ajustar de la referencia" ordenada por impacto (ej: subir contraste del texto secundario a AA, adoptar el max-width 1216px de neon, reducir 400KB de fuentes). Si aplica, guarda el drenado de la referencia como inspiracion (drain_post / brain).

## Reglas
- CERO invento: todo valor viene del DOM real (getComputedStyle) o del network real.
- Contraste: usa la formula WCAG (luminancia relativa); marca AA (>=4.5 texto normal, >=3 grande) y AAA (>=7).
- Si la pagina tiene splash/animacion, espera a que asiente antes de medir.
- Respeta la identidad de Luis (ej. Forge = monocromo, morado solo acento): las mejoras deben caber en SU sistema, no clonar ciego.
- Entrega SIEMPRE: (a) los 2 screenshots, (b) la tabla comparativa, (c) el top 3-5 de mejoras accionables.
