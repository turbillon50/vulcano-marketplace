---
name: metodo-apps
description: Método único de Luis para CONSTRUIR una app nueva o RESCATAR una existente con calidad agencia (Higgsfield 4k) — del splash de carga al intro, onboarding, producto, cuenta, admin, tiendas y el loop de agentes que no para hasta la lista en verde. ACTIVAR al arrancar cualquier app o rescate, o cuando Luis diga "hazlo con el método", "rescátala", "que quede como Momentum", "calidad Higgsfield", "súbela a las stores".
version: 1.1
fecha: 2026-09-24
origen: Momentum (vmomentum.site) M4–M8, VForge, Identy-Kit, VanDeFi, Goossip — sep-2026
complementa: SANIDAD.md (protocolo anti-bugs), LENTES.md (las 7 lentes), pwa-agencia-premium (piezas de marca 4k, efectos de carga/intro), contrato-pwa
---

# Método de apps — construir y rescatar

Una app de Luis se entrega cuando **una persona real la abre en su iPhone y todo se siente sólido**:
entra con el puro link, ve la marca correr sola, entiende qué es sin registrarse, se registra cuando
quiere operar, hace lo suyo sin callejones, y puede salir, borrar su cuenta y volver. Todo lo demás
es medio.

## 0. Reglas que ya costaron caro (no negociables)

1. **Medir antes de afirmar.** Nada de "ya quedó" sin ruta en producción 200 + captura WebKit MIRADA.
2. **El diseño de Luis es la ley.** Se reproduce exacto; el prompt solo describe lo que cambia.
   Decisiones de marca nuevas (logo, símbolo, navegación): opciones primero, él aprueba, luego se toca.
3. **Solo la paleta de la marca.** Ni un verde, azul o lila "de sistema" colado (Momentum: solo naranja
   y grises; WhatsApp verde solo en su botón). Siempre claro salvo que la marca diga otra cosa.
4. **Navegar sin cuenta** (estilo Airbnb/Booking). El registro aparece solo al operar.
5. **Sin datos inventados.** Ni métricas, ni montos, ni testimonios. Si no hay dato, se omite.
6. **Los datos reales de Luis no los crea ni publica el agente.** Se prueba con `zz-prueba-*` que se
   borra (Clerk + base) y que NUNCA queda publicado más allá de la captura.
7. **Barridos grandes, no parches de uno en uno** (20–50 mejoras por corrida).
8. **Lo que llega funcionando no se toca, se conecta.** Migraciones solo aditivas con `pg_dump` previo.
9. **Secretos nunca en logs, reportes ni commits.** `.env.produccion` fuera de git y se borra al terminar.
10. **Push al cerrar cada bloque.** Luis prueba en su teléfono en producción; commits locales no existen para él.

## 1. Arranque (antes de tocar código)

- `mci_quien_soy`, `mesh_estado`, `mci_estandares`, memorias del proyecto en el Brain y memoria de Luis.
- Si hay repo oficial, se clona (no se resume a mano). Worktree propio por agente (`/root/worktrees/<app>-bN`).
- Node 20, commits firmados `turbillon50 <turbillon50@gmail.com>`.

## 2. Rescate (si la app ya existe)

1. **Inventario medido**: todas las rutas (`find app -name page.tsx`), cada una en producción con WebKit
   390 sin sesión y con sesión: código HTTP, redirección final, desborde horizontal
   (`scrollWidth - innerWidth`), errores de consola, texto visible. Tabla en `RESCATE.md`.
2. **Qué está vivo de verdad**: API/DB/auth/pagos con prueba real (no por existencia de env var).
3. **Mapa de basura**: rutas muertas, IA heredada sin uso, pantallas duplicadas, mocks en producción.
4. **Decisión con Luis en una sola lista**: se queda / se arregla / se quita. Lo que "funciona raro pero bien"
   se conserva y se pule; no se reescribe de cero lo que ya sirve.
5. Luego se sigue el método desde §3 sobre lo que quedó.

## 3. Primera impresión: carga → intro → onboarding

### 3.1 Splash / pantalla de carga (ver `pwa-agencia-premium` §1–§3)
- Arte de Luis → **Higgsfield 4k**: `gpt_image_2` 9:16 y 16:9 propios (escritorio no es el vertical estirado),
  ícono 1:1 con wordmark, símbolo SVG en `recraft_v4_1`, animación 5 s en `seedance_2_0` con **`--end-image`**
  (termina pixel-perfect en el diseño).
- Tres capas: poster → video (play manual) → WebP animado si Safari bloquea autoplay. Reduced-motion = poster.
- **Nunca depender solo de JS**: fallback CSS que retira el splash solo (VForge se quedaba "cargando" para
  siempre). Máximo ~4–5 s; "toca para saltar" desde el primer frame.
- Head kit completo: favicon, 192, 512 (any + maskable), apple-touch, og 1200×630, manifest, theme-color.

### 3.2 Intro (`/bienvenida`)
- 3–4 láminas máximo, una idea por lámina, botón **Saltar** siempre visible, se muestra una sola vez
  (recordado), y termina en la app navegable, no en un registro.

### 3.3 Onboarding (solo cuando la persona decide registrarse)
- **Por selección múltiple**, casi sin teclear: rol primero (ej. fundador / profesionista / inversionista /
  promotor), luego 3–5 preguntas del rol. Plantillas precargadas.
- Al final, frase explícita: "Tu cuenta quedó creada con **correo@…**" y el siguiente paso con un botón.
- Formularios largos (publicar un proyecto) = **wizard** de 10–15 preguntas con la tarjeta en vivo al lado,
  autoguardado, "Saltar" en lo opcional, y medidor "Listo para publicar".

## 4. Producto

- **Celular primero** (390/375/430), escritorio con más información, no estirado.
- Tab bar inferior en móvil con íconos + etiquetas; cero toggle flotante; `overflow-x: clip` en html/body;
  todo scroll programático dentro de su contenedor (un `scrollIntoView` corrió Momentum de lado).
- Tarjetas "de primer nivel": rieles deslizables tipo Uber Eats, cada riel con su criterio real y sin repetir
  el primero; portadas dignas (nunca una web de escritorio encogida; marco de dispositivo o logo grande sobre
  la marca); logos reales o iniciales bien hechas; sin franjas por `object-fit`.
- Estados vacíos con acción; esqueletos de carga; sin saltos de layout; página sin conexión.
- Privacidad por proyecto (abierto / discreto / NDA con firma y hash) cuando hay información sensible.
- PDF descargable por ficha que respete la privacidad.
- Conector MCP opcional para que la IA del usuario llene su información (nunca publica sola).

## 5. Cuenta (requisito de tiendas)

- Una persona = una cuenta, entre por Google, GitHub o correo (ligado por correo verificado; sin filas
  duplicadas ni "estacionadas").
- Arriba de Mi espacio: "Sesión iniciada como **correo**", **Cambiar foto** y **Cerrar sesión** siempre visibles.
- Foto desde cámara/galería; sin foto, iniciales en el color de marca. Nombres capitalizados al mostrar.
- Cerrar sesión limpio (caché, service worker, botón atrás sin datos). Sesión vencida → aviso y regreso al mismo lugar.
- **Eliminar cuenta dentro de la app** (confirmación escrita, borra Clerk + base, baja lo público, correo) y
  página pública `/eliminar-cuenta` sin sesión.
- `/legal`, `/legal/privacidad`, `/legal/terminos`, `/legal/datos`, `/soporte` enlazados en pie y en Tu cuenta.
- Contenido de usuarios: reportar, bloquear, filtro de palabras, términos 18+, respuesta de moderación.

## 6. Panel `/admin` profesional (toda app con usuarios)

Tablero (nuevos, publicados, mensajes, reportes, embudo, errores) · Usuarios (buscar, verificar,
**banear/suspender**, rol, eliminar, "ver como" solo lectura) · Contenido (aprobar, despublicar, **destacar y
ordenar rieles**, editar) · Moderación (cola de reportes, veto por dominio, palabras) · Avisos a segmentos con
doble confirmación · **Bitácora de auditoría** de toda acción · 404 para quien no es admin (página y API).

## 7. Tiendas

- **Google Play (primero)**: TWA con Bubblewrap, `assetlinks.json` con la huella real, AAB firmado con la llave
  respaldada fuera de git, íconos maskable, 8 capturas 1080×1920 reales, gráfico 1024×500, textos, cuestionario de
  Seguridad de los datos y clasificación IARC prellenados, cuenta de prueba para revisores. Cuenta de organización
  evita los 12 testers × 14 días.
- **Apple (después)**: una web en marco se rechaza (regla 4.2) → envoltorio nativo (Capacitor) con funciones del
  teléfono (push nativo, cámara, Face ID) y **Sign in with Apple** si hay Google/GitHub.
- Todo queda en `STORES-CHECKLIST.md` con la ruta donde se cumple cada requisito.

## 8. Cómo se ejecuta: el loop

1. **Brief ejecutable** `BRIEF-<corrida>.md` en el repo: lo que dijo Luis literal, reglas, bloques con criterio de
   aceptación. Correcciones nuevas se agregan como bloques con prioridad y se reinicia al agente (matar su PID;
   el supervisor lo relanza con el brief nuevo — un `claude -p` lee su misión una sola vez).
2. **Lista maestra** (`LISTA-*.md`) como fuente de verdad: [x] solo con evidencia; [LUIS] lo que solo él puede
   hacer. Al terminarla, el agente re-audita la app completa y agrega lo nuevo. `DONE-*` solo con todo en [x].
3. **Supervisor** `/root/sup-<corrida>.sh`: `flock` + `while true` relanzando `claude -p "$(cat BRIEF)"` hasta
   que exista `DONE-*`; cron `*/10` como respaldo.
4. **Vulcano revisa cada hora** (scheduled task): log, commits vs `origin/master` (sube lo que lleve >1 h),
   agente vivo, secretos en git = 0, zz-prueba = 0, capturas nuevas **miradas**; desmarca lo que no se sostenga.
5. **Cierre**: quitar supervisor del cron, borrar `.env.produccion`, pruebas del nocturno en verde, hoja de
   capturas, reporte honesto a Luis: qué quedó, qué no, y qué le toca a él (con ruta exacta).

## 9. QA mínimo antes de decir "listo"

- WebKit (no Chrome, da falsos verdes) en 375/390/430 y 1440, **con y sin sesión**, y tras interacciones
  (cambiar pestañas, filtros, atrás).
- Las rutas: 200 o redirección correcta; 0 desbordes; 0 errores de consola; 0 respuestas 500.
- Contraprueba: correr a mano un caso que DEBE fallar para comprobar que la prueba reprueba.
- Mirar cada captura. Si Luis manda una captura de su iPhone, se toma como verdad por encima de las nuestras.

**Auditoría obligatoria:** toda app se audita contra `MUST-500.md` (esta carpeta): 500 obviedades verificables; los [Regresión] se prueban siempre. Resultado en `MUST-500-<app>.md` con evidencia.

## 10. Las 7 lentes (`LENTES.md`)

Antes de programar una app nueva se pasan las lentes 1–5 (plano, hero, movimiento, redacción, plan de
construcción); con la app en producción, la 6 (auditoría de conversión: fricciones por impacto, 3 cambios,
métrica que lo prueba); al cerrar el loop, la 7 (plan de lanzamiento de 30 días con experimentos y criterio de
parar). En rescate: `RESCATE.md` → lente 6 sobre lo que hay → 1–5 solo sobre lo que se rehace → 7. Cada lente
termina en renglones de `LISTA.md` con criterio medible; prosa sola no cuenta. Las lentes no inventan marca
(la de Luis es la ley) ni datos (testimonios, cifras, logos).

## 11. Sanidad: cada botón hace lo que dice (`SANIDAD.md`)

Cada elemento interactivo es una promesa escrita en `PROMESAS.md` con su consecuencia y su prueba. El
corredor `qa/sanidad.mjs` toca todo con y sin sesión (veredictos NAVEGA/CAMBIA/PIDE/DIALOGO/MUERTO/ERROR/
FUERA), verifica las consecuencias donde viven, mide los diálogos, y corre las regresiones R-001…R-010
(las causas de "app pasmada" ya medidas). Corre rápido tras cada deploy y completo cada noche; resultados
en `sanidad_corridas` y `/admin/sanidad`. Ningún botón nuevo sin promesa y prueba; ningún bug cerrado sin
regresión; ningún verde sin contraprueba. La lista maestra gana la sección S (S1–S6).
