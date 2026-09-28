---
name: pwa-agencia-premium
description: Protocolo de calidad agencia premium para PWAs de Luis (V·Momentum). Cómo se producen, adecúan (celular → escritorio), implementan y verifican piezas visuales de marca (carga/splash, ícono, símbolo, animaciones, efectos cristal) con Higgsfield por CLI y Next.js. ACTIVAR cuando se prepare la ficha o el empaque de Google Play, cuando se defina o audite la paleta de color, cuando se construya o retoque cualquier pantalla de producto propio o de cliente que deba verse "de agencia", cuando se hable de splash, pantalla de carga, ícono de app, head kit, animación de marca, o cuando Luis diga "calidad agencia", "premium", "4k", "que corra solo", "adecúalo a computadora".
version: 2.0
fecha: 2026-09-24
origen: Carga de Momentum (vmomentum.site), sesión 22-sep-2026
---

# PWA calidad agencia premium — protocolo

Nació de la carga de Momentum: tres errores míos en una tarde (aplané el diseño de Luis,
le quité el wordmark al ícono, confié en el autoplay de Safari) y su corrección. Este
protocolo existe para que no se repitan.

## 0. Reglas de oro (no negociables)

1. **El diseño de Luis es la ley.** Si manda una imagen, se reproduce EXACTA: mismo tile,
   mismas bandas de luz, mismo wordmark, mismos micro-textos, mismas micro-sombras. Nada
   se "simplifica", nada se "mejora" sin que él lo pida. El prompt describe lo que CAMBIA
   (quitar marco de teléfono, subir resolución), nunca redescribe el diseño con palabras
   propias (ahí es donde se pierde el tile o el wordmark).
2. **Celular primero, escritorio adecuado.** Luis diseña en celular. Escritorio NO es el
   asset vertical estirado con `object-fit: cover`: es una composición 16:9 propia
   (bloque central proporcional, bandas de luz reacomodadas) generada con la misma
   referencia. En piezas con contenido, escritorio siempre lleva MÁS información que
   celular, no la misma escalada.
3. **Tiene que correr solo.** Nada de marca depende del autoplay del navegador. Safari en
   bajo consumo bloquea `<video>` y pinta un botón de play encima (Luis lo vio en prod).
   Siempre hay respaldo que corre como imagen (WebP animado) y poster fijo debajo.
4. **Máxima calidad disponible.** 4k en imagen (GPT Image 2 `--resolution 4k`) y en video
   (Seedance 2.0 `--resolution 4k --bitrate_mode high`). No se baja calidad "para
   ahorrar"; se optimiza el peso en la entrega (derivados), no en la fuente.
5. **Mirar antes de entregar.** Toda pieza se abre y se mira (frames del video también).
   Toda pantalla se captura en WebKit en móvil y escritorio, con autoplay bloqueado y
   permitido. Sin captura mirada, no está hecho.
6. **Preguntar antes de generar algo de marca nueva; ejecutar sin preguntar cuando la
   referencia ya existe.** Luis aprueba marca; no aprueba comandos.

## 1. Producción de assets (Higgsfield por CLI en el Hetzner)

Entorno: `export HOME=/root` (cuenta turbillon50). Siempre `nohup … &` con salida a
`/root/hf/out-<nombre>.json` y `--wait --json`; nunca bloquear el relay.

| Pieza | Modelo | Parámetros | Notas |
|---|---|---|---|
| Splash móvil | `gpt_image_2` | `--image <ref> --aspect_ratio 9:16 --resolution 4k --quality high --batch_size 2` | Prompt "reproduce EXACTO… quita teléfono/bezel/status bar… edge-to-edge" |
| Splash escritorio | `gpt_image_2` | igual con `16:9` | Prompt "adapta a 16:9 manteniendo marca idéntica; bloque central ≈ tercio del ancho; bandas de luz desde esquinas" |
| Ícono | `gpt_image_2` | `--image <ref-icono> --aspect_ratio 1:1 --resolution 4k` | "Mantén TODOS los elementos, incluido el wordmark"; sin esquinas redondeadas (las pone el sistema) |
| Símbolo vectorial | `recraft_v4_1` | `--model_type vector --colors @colors.json --background_color "#RRGGBB" --resolution 2k` | Devuelve SVG real; es el que va en nav/favicon. `background_color` es string, no JSON |
| Animación splash | `seedance_2_0` | `--end-image <splash final> --duration 5 --resolution 4k --bitrate_mode high` | **end-image, no start-image**: el video termina pixel-perfect en el diseño y el modelo solo inventa la entrada. Prompt: escena sin elementos → tile crece con rebote → nodos pop-in y trazos se dibujan → wordmark sube → tagline → barra llena → caption → barrido de luz → "ends exactly on the provided end frame" |
| Kling 3.0 en paralelo | `kling3_0` | mismo end-image | Opcional como segundo candidato; el 22-sep se cayó sin salida. Seedance es el titular |
| Referencias de cristal | `gpt_image_2` | 9:16 / 16:9, 2k | Sólo referencia visual; el cristal real se implementa en CSS (§4) |

Trampas medidas:
- El CLI **no sube JPEG** (S3 `SignatureDoesNotMatch`); referencias siempre **PNG**. Subir
  una vez con `higgsfield upload create ref.png --json` y reutilizar el UUID.
- `--batch_size 2` devuelve 2 URLs en `results`; elegir mirando, no por orden.
- Prompt-only (Recraft, Z Image, Soul Cast/Location) rechazan `--image`.
- 4k tarda ~2–3 min imagen, ~6–8 min video. Programar check-in, no dormir el relay.

## 2. Derivados para entrega (en el repo, `public/carga/`)

```
mobile.mp4   4k original (≈2.4 MB)          desktop.mp4  4k original (≈2.3 MB)
mobile.webp  ffmpeg fps=15 scale=810:-2 q78 desktop.webp fps=15 scale=1440:-2 q78   ← respaldo que corre solo
mobile.jpg   poster 1080×1920 q90            desktop.jpg  poster 1920×1080 q90
```
Head kit desde el ícono 4k (PIL, LANCZOS, nunca upscale): `icon-512.png`, `icon-192.png`,
`apple-touch-icon.png` (180), `favicon.ico` (16/32/48), `og.jpg` 1200×630 desde el
splash de escritorio, `manifest.webmanifest` (name, theme/background `#FF6B2C`, icons
any+maskable).

## 3. Implementación de la carga (Next.js App Router)

Patrón validado en `app/page.tsx` ("use client"):
1. **Forma de pantalla decide la pieza**: `matchMedia("(min-aspect-ratio: 1/1)")` →
   escritorio; si no, móvil. No por ancho: un iPad en horizontal es escritorio.
2. **Capa 1, poster `<img fetchPriority="high">`** siempre pintado. Primer frame sin hueco.
3. **Capa 2, `<video muted playsInline preload="auto" disablePictureInPicture>`** con
   `opacity:0` hasta `onPlaying` (clase `viva`). Se llama `v.play()` a mano; si rechaza
   (`NotAllowedError`) o no arranca en 1.2 s → **capa 3**.
4. **Capa 3, `<img src=…webp>`** animado: corre como GIF, ningún navegador lo bloquea.
5. `prefers-reduced-motion: reduce` → sólo poster.
6. CSS: `html,body{overflow:hidden;background:#FF6B2C}`,
   `.carga{position:fixed;inset:0;isolation:isolate}`, hijos `object-fit:cover`,
   `video::-webkit-media-controls{display:none!important}` y
   `::-webkit-media-controls-start-playback-button{display:none!important}`.
7. `layout.tsx`: metadata con `manifest`, `icons` (ico + 192 + apple), `openGraph.images`,
   `viewport.themeColor` y `viewportFit: "cover"`.

## 4. Efecto cristal (cuando la pantalla lo pida)

Base honesta (design-taste-frontend Apéndice C): `backdrop-filter: blur(24px)
saturate(180%) contrast(1.05)`, fondo `linear-gradient(135deg, #fff30%, #fff8%) + #fff12%`,
borde `1px #fff32%`, `box-shadow: inset 0 1px 0 #fff48%, inset 0 -1px 0 #fff12%,
0 18px 60px #0003`, `::before` con highlight radial en 20% 0% y `::after` rim interior
`inset:1px; border:1px #fff14%`. Fallback sólido bajo `prefers-reduced-transparency`.
Referencias visuales de Momentum: tab bar flotante en pastilla (móvil) y nav flotante
(escritorio) generadas el 22-sep en `/root/hf/out-glass-*.json`.

## 5. Verificación obligatoria (WebKit, en el Hetzner)

`PLAYWRIGHT_BROWSERS_PATH=/dev/shm/trama-conversations-browser` (WebKit 2104) o
`/dev/shm/root-cache-20260916/ms-playwright`. Script patrón: `/root/hf/shot2.mjs`.
Cuatro capturas mínimas: móvil 393×852 y escritorio 1440×900, cada una con autoplay
**bloqueado** (`addInitScript` que hace `HTMLMediaElement.prototype.play` rechazar) y
permitido. Verificar por DOM: bloqueado → `img[src$=".webp"].viva` y sin `<video>`;
permitido → `<video>` y `.viva`. Y MIRAR las capturas. Además `curl` de cada asset (200 y
tamaño) y `/api/buscar/estado` 200 (cableado vivo).

## 6. Git / deploy

Worktree propio (`/root/worktrees/momentum-b1`, rama `carga`), Node 20 por nvm,
`rm -rf .next && npx next build && npx tsc --noEmit` antes de commit; commit firmado
`turbillon50 <turbillon50@gmail.com>` con trailers de sesión; `git push origin
carga:master` despliega en Vercel. Todo en `setsid nohup script > log &` con sentinela
(`CARGA4K-OK`) y check-in por scheduled task; nunca `pkill -f` con patrón que matchee al relay.

## 7. Checklist de entrega

- [ ] Pieza idéntica a la referencia de Luis (tile, bandas, wordmark, micro-textos, micro-sombras)
- [ ] 4k fuente + derivados ligeros; SVG para el símbolo
- [ ] Móvil 9:16 y escritorio 16:9 propios, no estirados
- [ ] Corre solo: poster → video → WebP; reduced-motion respetado
- [ ] Head kit completo (ico/192/512/apple/og/manifest/theme-color)
- [ ] 4 capturas WebKit miradas + curl de assets + API viva
- [ ] Cableado intacto (Clerk/Neon/Stripe/APIs) — nada del `app/api`, `lib`, `proxy.ts` tocado
- [ ] Reporte a Luis: qué, con qué modelo, a qué resolución, y qué NO quedó


## 8. Color: el sistema que no se rompe (v2, 24-sep-2026)

Lección de Momentum: verde "de éxito", azul de pestaña y lila de chips se colaron desde componentes
genéricos y Luis los vio en su iPhone. Regla:
1. **Paleta cerrada en tokens** (`:root`): `--marca` (+ `--marca-600/700` para hover/presionado),
   `--marca-suave` (fondos 6–10%), `--tinta`, `--tinta-2`, `--tinta-3`, `--papel`, `--papel-2`, `--linea`,
   y SOLO dos semánticos: `--peligro` (rojo para borrar/errores) y `--aviso` (ámbar). **No existe `--exito` verde**:
   "bien/completado/disponible" = `--marca` o gris con palomita.
2. Cero colores literales en componentes: `git grep -nE '#[0-9a-fA-F]{3,6}|rgb\(' app components` solo puede
   apuntar a `globals.css`. Prueba automática que falle si aparece un hex fuera de tokens.
3. Excepciones con nombre y justificación: botón WhatsApp (verde oficial), logos de terceros.
4. Contraste AA (4.5:1 texto, 3:1 íconos) medido, no a ojo; naranja sobre blanco solo en ≥18 px o bold.
5. Siempre claro salvo marca oscura aprobada; nada de modo oscuro automático que invente colores.
6. Ícono, splash, favicon, capturas de tienda y gráficos salen de la MISMA paleta.

## 9. Google Play: piezas de ficha con calidad agencia (v2)

Todo se produce desde la marca aprobada y se MIRA antes de subir. Carpeta: `store/play/` en el repo.

| Pieza | Medida exacta | Cómo se hace |
|---|---|---|
| Ícono de la ficha | 512×512 PNG 32 bits, sin transparencia en esquinas (Play redondea) | Del ícono 4k (gpt_image_2) con PIL LANCZOS; símbolo + wordmark si cabe legible, si no solo símbolo |
| Ícono adaptativo (app) | capa frontal 432×432 con zona segura 264×264 + fondo sólido `--marca` | Símbolo SOLO (sin wordmark) centrado en la zona segura; probar máscara círculo, squircle, gota |
| Favicon / 16–48 | ico multi-tamaño | SOLO símbolo; el wordmark a 16 px es una mancha |
| Gráfico destacado | 1024×500 JPG/PNG sin transparencia | gpt_image_2 16:9 4k con la referencia de marca → recorte 1024×500; nada de texto crítico en los bordes (Play lo tapa con el botón de play si hay video) |
| Capturas de teléfono | 8 × 1080×1920 (9:16), reales de producción | WebKit 1080×1920 @dpr1 o 360×640 @dpr3 con datos reales (no zz); marco opcional + titular corto arriba en la tipografía de marca, fondo `--marca-suave`; orden: valor principal → explorar → ficha → publicar → cuenta → confianza (legal/privacidad) |
| Capturas tablet (opcional) | 7" 1200×1920 y 10" 1600×2560 | Mismo guion; mejora el ranking si la app se ve bien en tablet |
| Video promo (opcional) | YouTube, 30 s | HyperFrames con capturas reales + splash; sin música con derechos |

Textos de ficha (español México): título ≤30, descripción corta ≤80, larga ≤4000 sin mayúsculas gritonas ni
emojis de relleno, sin promesas de dinero; categoría, correo de soporte, URL de privacidad, URL de
eliminación de cuenta. Cuestionarios: Seguridad de los datos (qué se recopila, para qué, si se comparte,
cifrado en tránsito, cómo borrar) y clasificación IARC. Todo prellenado en `STORES-CHECKLIST.md`.

Empaque TWA (Bubblewrap): `twa-manifest.json` con `packageId`, `themeColor`/`navigationColor` = `--marca`
o `--papel`, `backgroundColor` = color del splash, `enableNotifications: true`, `fallbackType: customtabs`,
ícono adaptativo y monocromático (Android 13). `assetlinks.json` con la SHA-256 de la llave de subida Y la
de firma de Play (App Signing). La llave `.keystore` se respalda fuera de git (chmod 600) y en el Brain solo
su ruta. Verificación: instalar el APK en un emulador/dispositivo, que abra SIN barra de URL (si aparece,
assetlinks está mal) y que el splash nativo use el color de marca.

Checklist Play (se suma al §7):
- [ ] Paleta cerrada, prueba de hex en verde, contraste AA medido
- [ ] Ícono 512, adaptativo con máscaras probadas, favicon solo símbolo
- [ ] Gráfico 1024×500 y 8 capturas 1080×1920 reales, mirados en un teléfono
- [ ] Textos y cuestionarios prellenados; URLs de privacidad, soporte y eliminación en 200
- [ ] AAB firmado, llave respaldada, assetlinks con ambas huellas, app sin barra de URL
