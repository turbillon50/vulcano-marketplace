---
name: icono-pwa
description: OBLIGATORIO en TODA app. El icono de la PWA (el que aparece al instalar la app en escritorio o celular) DEBE ser el LOGO real de la marca, no un placeholder, ni en blanco, ni el de v0/Vercel. Es lo que hace que se vea profesional y no pirata al instalarse. ACTIVAR al cerrar cualquier app, en el gate de calidad/Definicion de Terminado, o cuando Luis diga no tiene icono, el logo del escritorio, se instala sin logo, sale en blanco al instalar.
---
# Icono de PWA (logo de la app instalada) — OBLIGATORIO

Al instalar una PWA, el icono del home/escritorio sale del manifest + meta. Si faltan o son placeholder, se ve pirata. Requisito de cierre:

## Archivos (en public/icons o public/)
- icon-192.png (192x192), icon-512.png (512x512), icon-maskable-512.png (512x512, purpose maskable, con safe-zone), apple-touch-icon.png (180x180), favicon.ico. TODOS = el LOGO real de la app.
- Si no existen o son genericos: generarlos desde el logo de la marca (sharp / build-icons.mjs). Maskable con padding ~10-12% para que no se corte.

## Wiring
- manifest.webmanifest: array icons con src, sizes, type image/png, purpose (any y maskable). name/short_name correctos.
- <head>: <link rel="apple-touch-icon" href="/icons/apple-touch-icon.png">, <link rel="icon" ...>, theme-color, apple-mobile-web-app-title con el nombre de la app.

## Verificacion (parte del gate)
- Los iconos responden 200. Instalar la PWA y CONFIRMAR que el icono del home/escritorio es el logo (no blanco/generico). En iOS revisar apple-touch-icon (iOS no usa el maskable).
