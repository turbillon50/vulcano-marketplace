---
name: contrato-premium
description: Generar contratos con diseño espectacular en hoja membretada VMomentum (PDF). ACTIVAR cuando se necesite un contrato, machote, anexo, NDA, o cuando Luis diga "contrato", "membretada", "documento legal", "para firma". Produce contratos legales legibles con membrete corporativo, cláusulas sin cortes feos de página, y listos para DocuSign.
---
# CONTRATO PREMIUM — hoja membretada VMomentum

## Diseño obligatorio
- **Hoja membretada en TODAS las páginas del contrato** via CSS Paged Media (WeasyPrint): `@page contrato { @top-left { content: element(membrete) } @bottom-center { content: element(piecontrato) } }` con margen superior 34mm.
- **Membrete**: logo texto "VMomentum" (V navy #0e1b33 + Momentum cyan #06b6d4), línea derecha "Contrato de Prestación de Servicios · All Global Holding LLC", regla inferior azul #2563eb + barra degradado #2563eb→#06b6d4.
- **Pie**: "VMomentum · All Global Holding LLC · Delaware, EUA · vmomentums.info · Documento confidencial".
- **Portadilla del contrato**: caja gris clara centrada con título + sello pill azul ("Documento legal").
- **Cláusulas**: `page-break-inside: avoid` SIEMPRE (nunca una cláusula partida ni huecos blancos entre páginas), borde izquierdo fino gris, encabezados de cláusula en azul #2563eb mayúsculas, texto justificado 9pt, tablas de pagos con header navy.
- **Campos por rellenar**: línea baja (border-bottom) en blanco — nunca texto de ejemplo de otro cliente.
- Paleta: navy #0e1b33, azul #2563eb, cyan #06b6d4, gris #5b6473. CERO dorado.

## Estructura del machote (12 cláusulas — fuente: contrato base de Luis)
Declaraciones (ciudad/fecha/plataforma) · A. Prestador (Luis Humberto de la Torre Herrera, All Global Holding LLC, Delaware) · B. Cliente (en blanco) · C. Las partes · 1 Objeto · 2 Alcances y entregables (Anexo A) · 3 Contraprestación: $12,000 MXN en 3 hitos de $4,000 (firma/integraciones/entrega), Mercado Pago, CLABE en blanco · 4 Plazos: 15 días hábiles testing + 10 producción (25 máx) · 5 Obligaciones prestador (bugs ≤96h hábiles) · 6 Obligaciones cliente (aprobación tácita 48h) · 7 Propiedad intelectual (cliente: app/código/dominio/DB al liquidar; prestador: método/herramientas; portafolio salvo pacto) · 8 Confidencialidad 2 años · 9 Terminación anticipada (5 días subsanar) · 10 Buena fe · 11 Jurisdicción Cancún, Q.R. · 12 Aceptación + firmas.
Stores opcionales: iOS $5,000 / Android $3,000, sujetos a tiempos de Apple/Google.

## Generación
Plantilla viva: `entrega-cliente/plantilla/propuesta-vmomentum-pdf.html` en skills-vault (el contrato es la sección `.ctr`). Render: `python3 -c "import weasyprint; weasyprint.HTML('archivo.html').write_pdf('Contrato.pdf')"`.

## Futuro
Versión navegable en vforge.site/vmomentums.info con formulario que llena los campos y firma vía **DocuSign**. Encadena con: [entrega-cliente], [manifiesto-app].
