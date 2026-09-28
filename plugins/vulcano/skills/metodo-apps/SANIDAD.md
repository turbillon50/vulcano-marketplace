# Protocolo de Sanidad — anti-bugs, anti-pasmadas, verificación constante

Origen: Momentum, 24–25 sep 2026. En una noche Luis encontró desde su iPhone cuatro cosas "pasmadas" que
ninguna prueba había visto: un recortador invisible, un "Así te ven" que no abría, una portada que no se
dejaba acomodar y textos que no se guardaban. Las cuatro tenían causa raíz distinta y las cuatro eran
**promesas rotas**: un botón que dice algo y no lo hace. Luis: *"una sola parte que se trabe y perdemos
usuarios"*.

El MUST-500 dice qué debe cumplir una app en general. Este protocolo dice cómo se comprueba, **todos los
días y en cada deploy**, que **cada botón de ESTA app hace lo que dice y produce su consecuencia** en el
resto de la app. No es una lista más: es un corredor que se ejecuta.

## 0. Principios

1. **Cada elemento interactivo es una promesa.** Botón, enlace, pestaña, campo, gesto. Si existe, promete
   algo. La promesa se escribe (qué pasa al tocarlo) y se comprueba. Un botón sin promesa escrita no se sube.
2. **Toda acción tiene consecuencia observable.** Guardar → se ve guardado en otro lado. Seguir → sube un
   contador y aparece en "Siguiendo". Reportar → hay un renglón en /admin y un acuse para quien reportó. La
   consecuencia se verifica en el lugar donde vive (otra pantalla, la base, un correo), no solo el toast.
3. **Un toque sin efecto es un bug.** Si al tocar no pasa nada observable (ni navegación, ni cambio en el
   DOM, ni petición de red, ni toast) en 1.5 s, es un botón muerto y se reporta. Igual si abre un diálogo que
   no está dentro de la pantalla.
4. **Lo que se rompió una vez se vigila para siempre.** Cada bug arreglado deja una prueba con su id
   (`[Regresión]`) en el corredor. Nunca se cierra un bug sin su prueba.
5. **Verde sospechoso.** Toda corrida con 100 % en verde se contraprueba rompiendo algo a propósito y
   comprobando que el corredor lo ve. Una prueba que no sabe fallar no es prueba.
6. **Se prueba con sesión y sin sesión**, en WebKit 390 y Chromium 1440, con la cuenta `zz-prueba-*` que
   se borra al final. Nunca con datos reales de Luis.

## 1. Inventario de promesas (`PROMESAS.md` en el repo)

Una tabla viva, generada en parte por el corredor (rastrea todo `button`, `a`, `[role=button]`,
`[role=tab]`, `input[type=file]`, `form`) y completada a mano con la consecuencia esperada:

| id | Pantalla | Elemento (texto / aria-label) | Requiere sesión | Promesa (qué pasa al tocar) | Consecuencia (dónde se ve) | Prueba |
|---|---|---|---|---|---|---|
| P-042 | /perfil/editar | "Guardar" | sí | PUT /api/perfil 200, toast "Guardado" | `perfiles` actualizado; /@handle muestra el cambio; header muestra el nombre | `sanidad.mjs#P-042` |
| P-043 | /perfil/editar | "Cambiar foto" | sí | abre recortador (dentro de pantalla) → sube → avatar cambia | header, tab bar, /@handle, tarjeta del directorio | `#P-043` |
| P-101 | /proyecto/[slug] | "Guardar" (bookmark) | sí (sin sesión: hoja de invitación) | toggle + toast | aparece en /guardados; contador de guardados del proyecto | `#P-101` |
| P-102 | /proyecto/[slug] | "Seguir" | sí | toggle | /mi-espacio → Siguiendo; contador en la ficha; aviso al dueño | `#P-102` |
| P-120 | /proyecto/[slug] | "Reportar" | sí | hoja con motivo → POST 201 | renglón en /admin/moderacion; acuse en Mi espacio → Moderación | `#P-120` |

Regla: **cada renglón nuevo del inventario nace con su prueba**. El corredor falla si encuentra un elemento
interactivo que no está en el inventario (`SIN PROMESA`).

## 2. El corredor (`qa/sanidad.mjs`)

Se corre con `node qa/sanidad.mjs [--solo P-042] [--sin-sesion] [--rapido]`. Hace, en orden:

1. **Rastreo**: todas las rutas (`find app -name page.tsx` + rutas dinámicas con un slug real de la casa),
   con y sin sesión. Por ruta: HTTP, redirección final, `scrollWidth ≤ innerWidth`, 0 errores de consola,
   0 respuestas ≥ 400 en la red de la página, `<h1>` presente, texto ≥ 200 caracteres (no está en blanco),
   sin "undefined"/"null"/"NaN"/"[object Object]" visibles, sin claves de i18n crudas (`landing.titulo`).
2. **Toque de todo**: por cada elemento interactivo visible: registra estado antes (URL, DOM hash, red,
   toasts, diálogos), lo toca, espera 1.5 s, registra después. Veredictos: `NAVEGA`, `CAMBIA`, `PIDE`
   (petición de red), `DIALOGO` (y mide: caja dentro del viewport, ≥ 1 botón visible, cierra con Escape),
   `MUERTO` (nada cambió → bug), `ERROR` (consola o red ≥ 400 → bug), `FUERA` (diálogo fuera de pantalla →
   bug). Después de cada toque vuelve al estado anterior (atrás, Escape, o recarga).
3. **Promesas con consecuencia**: ejecuta las pruebas escritas del inventario (`#P-…`): hace la acción y
   verifica la consecuencia en su lugar (otra ruta, consulta a la base con `DATABASE_URL`, correo de prueba
   en la bandeja `zz`). Lo mínimo por app con usuarios: registro → sesión → editar perfil (texto + foto) →
   publicar → guardar/seguir/contactar/reportar → cerrar sesión → volver a entrar → eliminar cuenta, y que
   cada paso deje huella donde debe.
4. **Diálogos**: cada diálogo/hoja/visor conocido se abre y se mide (viewport, botón, cierre, foco de vuelta).
5. **Estados**: vacíos (con acción), cargando (esqueleto, no spinner infinito), error (mensaje + reintentar),
   sin sesión (invitación al operar, nunca fija), sin conexión (página propia + reintento).
6. **Regresiones**: las pruebas `[Regresión]` con su id (ej. `R-001 recortador dentro del viewport`,
   `R-002 main sin transform`, `R-003 sin regla body > *`, `R-004 portada 2.95:1`).
7. **Salida**: `SANIDAD-<fecha>.md` con tabla por veredicto, capturas de cada `MUERTO`/`ERROR`/`FUERA`, y
   `sanidad.json` para el tablero. Inserta un renglón en la tabla `sanidad_corridas` (fecha, commit, total,
   verdes, rojos, muertos, duración) para ver la tendencia. Código de salida ≠ 0 si hay rojos.

## 3. Cuándo corre

- **En cada push a producción** (después de `READY`): modo `--rapido` (rastreo + diálogos + regresiones,
  ~5 min). Rojo → el agente que subió lo arregla antes de seguir con lo suyo; Vulcano lo ve en el check-in.
- **Nocturno** (cron 03:00 hora México): completo, con sesión, en 390 y 1440. Reporte al log y renglón en
  `sanidad_corridas`. Si hay rojos nuevos, entra como bloque al brief del loop activo.
- **Antes de decir "listo"** cualquier bloque que toque UI: el agente corre `--solo` las promesas de las
  pantallas que tocó y pega la tabla en su commit.
- **Antes de una tienda o de mandar a un cliente**: completo + contraprueba del verde.

## 4. Anti-pasmadas (causas ya medidas; cada una tiene su regresión)

- R-001 Diálogo `fixed` con ancestro con `transform`/`filter`/`perspective`/`contain`/`will-change` → cae fuera
  de pantalla. Ningún contenedor de página (`body`, `main`, `.m-pagina`, formularios) anima `transform`.
- R-002 Fondo con `backdrop-filter` que anima opacidad → WebKit no pinta a sus hijos. La animación va en la caja.
- R-003 `body > *` / `body:has(...) > *` con `position` → mata los portales. Resplandores en `z-index: -1` con
  `isolation` en el body.
- R-004 Recortar con una proporción y pintar con otra → el usuario no puede acomodar la imagen. El marco de
  recorte usa la proporción exacta del contenedor final.
- R-005 Cinco dueños del bloqueo de scroll → la página se corre de lado. Un solo dueño con contador.
- R-006 `scrollIntoView` fuera de su contenedor → corre la página entera. Todo scroll programático dentro de su
  contenedor.
- R-007 Spinner sin tope → carga infinita. Todo indicador pasa a error con "Reintentar" a los 10 s.
- R-008 Toast/estado que depende de `await` de una acción de servidor lenta → nunca se pinta. El feedback es
  optimista y se corrige si falla.
- R-009 Sesión vencida a media acción → 401 mudo y se pierde lo escrito. Borrador en `sessionStorage`,
  aviso y regreso al mismo lugar.
- R-010 Botón con `pointer-events: none` heredado o tapado por una barra fija → no se puede tocar. El corredor
  detecta `MUERTO` y `elementFromPoint` ≠ el botón.
- R-011 Texto encimado. Tres causas medidas en Momentum (25-sep): (a) una decoración de tamaño fijo
  (pastilla de 1/n) sobre elementos que miden según su texto (`grid-auto-columns: 1fr` = `minmax(auto,1fr)`
  crece con `nowrap`); (b) sellos en posición absoluta que chocan cuando la tarjeta se angosta (rejilla de 4
  columnas en una columna de 780 px); (c) textos más largos en otro idioma o con otra fuente (iOS). Regla: lo
  que marca un elemento activo es fondo DEL elemento, no una pieza aparte con ancho calculado; tarjetas con
  ancho mínimo; `minmax(0,1fr)` + texto que se adapta. El corredor mide pares de textos visibles (cajas de
  Range recortadas por overflow, misma capa, sin `details` cerrados) que se crucen > 12 px² en 390 y 1440,
  ES y EN (`qa/vul-encimados.mjs` en Momentum).
- R-012 Dos fuentes para el mismo dato. La foto salía bien en Mi espacio y como ícono de GitHub en Explorar
  porque una pantalla leía la base y otra el proveedor de login. Un dato visible = UNA función que lo lee,
  en el mismo orden de prioridad (lo que subió la persona → base → proveedor). Prueba: sube una foto con
  `zz-prueba` y compárala en header, tab bar, perfil público, tarjeta y ficha.

## 5. Qué hace el agente cuando el corredor marca rojo

1. Reproduce con `--solo` y captura. 2. Busca la **causa raíz** (no el síntoma): mide computed styles,
red, base. 3. Arregla en el lugar correcto (token, regla global, contrato de API), no con un parche local.
4. Escribe la regresión `R-nnn` con la medición que la detecta. 5. Contraprueba: revierte el arreglo en
local y comprueba que la regresión falla. 6. Sube con push y verifica READY. 7. Anota en `SANIDAD-<fecha>.md`
causa raíz, arreglo y regresión.

## 6. Tablero

`/admin/sanidad` (o sección del tablero admin): última corrida, tendencia de rojos/muertos por día, lista de
promesas rojas con captura, y el botón "Correr ahora" que dispara el corredor en el servidor. Sin analítica no
hay tablero de negocio; sin sanidad no hay tablero de confianza.

## 7. Cómo entra en la fábrica

- `fabrica.sh` crea `PROMESAS.md` vacío y copia `qa/sanidad.mjs` plantilla desde
  `/root/skills-vault/metodo-apps/plantillas/sanidad.mjs`; el brief exige el inventario antes de cerrar §4
  del método y el corredor verde antes de §7 (tiendas).
- `LISTA-*.md` gana la sección "S · Sanidad": S1 inventario completo (0 `SIN PROMESA`), S2 corredor rápido
  en verde tras cada push, S3 nocturno en verde 3 noches seguidas, S4 contraprueba del verde anotada,
  S5 regresiones R-001…R-010 presentes y verdes, S6 tablero.
- MUST-500 §23 (diálogos) y §24 (promesas y consecuencias) apuntan aquí.
