# MUST-500: obviedades que toda app/PWA premium debe cumplir

Cómo usarla: el agente de QA recorre cada ítem en producción (celular primero: 390×844, luego 1440×900), marca ✅/❌ con evidencia (captura mirada, medición o comando) y todo ❌ bloquea la entrega; los ítems con [Regresión] ya fallaron antes y se prueban siempre.

## 1. Primera impresión (splash, carga e intro)

1. El primer contenido pintado (FCP) ocurre en ≤1.8 s en la home con Lighthouse móvil (4G lenta simulada).
2. El splash nunca dura más de 3 s: con el JS principal bloqueado o fallando, a los 3 s se ve contenido o un mensaje con botón "Reintentar". [Regresión] Prueba: DevTools > Network > bloquear el chunk principal y recargar.
3. El splash se oculta con un respaldo en CSS/HTML puro (animación con retardo), no depende solo de que hidrate React.
4. Existe <noscript> en español que explica que se requiere JavaScript e incluye un contacto.
5. El fondo del splash es igual al background_color del manifest y al primer frame de la app: sin destello blanco (comparar capturas a 0 ms y 300 ms).
6. Con el sistema en modo oscuro no hay destello blanco al cargar (tema aplicado antes del primer pintado).
7. El logo del splash se ve nítido a 3x DPR (SVG o PNG ≥3x su tamaño CSS).
8. Ningún indicador de carga es infinito: todo spinner pasa a estado de error con "Reintentar" a los 10 s como máximo.
9. Si el autoplay de un video falla (Safari iOS, modo de bajo consumo) se ve el póster estático, nunca el botón de play nativo gris. [Regresión] Prueba: iPhone con Modo de bajo consumo activado.
10. Todo <video> de fondo tiene muted, playsinline, autoplay, loop y poster (revisar atributos en el DOM).
11. La promesa de video.play() tiene catch que deja visible el póster; 0 errores "NotAllowedError" sin capturar en consola.
12. La intro/onboarding tiene botón "Saltar" visible desde el primer paso, de ≥44×44 px.
13. La intro se muestra una sola vez por dispositivo: al recargar no vuelve a aparecer.
14. El onboarding tiene ≤4 pantallas e indicador de progreso ("2 de 4" o puntos).
15. Título, subtítulo y CTA principal de la home son visibles sin scroll en 375×667 y en 1440×900.
16. Nada en la home depende de hover para entenderse (probado solo con toque).
17. En la primera visita aparece como máximo un aviso a la vez (cookies, notificaciones o instalar), nunca apilados.
18. El aviso de instalar la PWA no aparece en la primera carga; solo tras ≥2 interacciones significativas.
19. La primera carga no pide ningún permiso del navegador (notificaciones, ubicación, cámara) sin acción del usuario.
20. Abrir la app desde el ícono instalado con sesión activa lleva a la pantalla principal, no a /sign-in.
21. El HTML inicial (ver código fuente) ya contiene el título y el texto principal de la página, no solo tras hidratar.
22. La home carga con 0 errores de hidratación en consola ("Hydration failed", "Text content does not match").
23. Las fuentes no mueven el layout al cargar (next/font con fallback ajustado; CLS atribuible a fuentes = 0).

## 2. Registro, sesión y cuenta

24. Los botones "Continuar con Google", "Continuar con GitHub" y correo se ven sin scroll en /sign-in a 375×667.
25. Al cerrar sesión y volver a entrar con Google aparece el selector de cuentas de Google (prompt=select_account); nunca entra directo a la última cuenta. [Regresión] Prueba con 2 cuentas Google en el mismo navegador.
26. Al entrar con GitHub se puede elegir o cambiar de usuario de GitHub (se documenta y prueba el flujo con 2 cuentas).
27. El correo de la cuenta activa se ve en el menú de usuario en ≤2 toques desde cualquier pantalla. [Regresión]
28. Ajustes muestra el correo y el método de acceso (Google, GitHub o correo) de la sesión actual.
29. Entrar con GitHub con el mismo correo de una cuenta existente vincula la cuenta, no crea otro usuario. [Regresión] Prueba: registrarse con correo X, salir, entrar con GitHub correo X; SELECT count(*) por correo = 1.
30. La tabla de usuarios tiene UNIQUE en clerk_user_id y en correo normalizado (minúsculas, sin espacios).
31. El webhook user.created de Clerk es idempotente: reenviarlo 2 veces desde el panel deja 1 solo registro (upsert).
32. El webhook de Clerk valida la firma svix y responde 400 a una firma inválida.
33. user.updated y user.deleted sincronizan nombre, foto y borrado en la BD en ≤60 s.
34. El avatar es la foto del proveedor o la subida por el usuario; nunca el avatar genérico de Clerk cuando existe foto. [Regresión]
35. Sin foto, el avatar de respaldo muestra iniciales sobre un color de la paleta, no la silueta gris de Clerk.
36. Los nombres se guardan y muestran con mayúscula inicial ("Luis Delator", no "luis delator") respetando partículas ("de la Torre"). [Regresión]
37. El nombre visible nunca es el correo ni un id interno (user_2abc…).
38. "Cerrar sesión" está a ≤2 toques desde cualquier pantalla autenticada.
39. Tras cerrar sesión, el botón atrás no muestra páginas privadas con datos (Cache-Control: no-store en páginas autenticadas).
40. Cerrar sesión borra el estado local del usuario (localStorage, caché de consultas, cachés del SW con datos privados).
41. Existe "Cambiar de cuenta" que cierra la sesión actual y lleva a la pantalla de elegir método de acceso.
42. El código de verificación por correo es de 6 dígitos y llega en ≤60 s, desde un remitente con el dominio de la marca.
43. El correo de verificación está en español, con logo y colores de marca, y el código se copia con un toque.
44. "¿Olvidaste tu contraseña?" funciona y el flujo completo toma ≤3 pantallas.
45. El código o enlace de recuperación expira en ≤15 min y es de un solo uso (reusarlo muestra error claro).
46. Un login fallido muestra "Correo o contraseña incorrectos" sin revelar si el correo existe.
47. Tras 5 intentos fallidos se activa límite o captcha (protección contra bots de Clerk encendida).
48. La sesión sobrevive a cerrar y reabrir la PWA/TWA durante ≥7 días sin pedir login.
49. Si la sesión expira, se redirige a /sign-in con redirect_url y al entrar regresa a la página donde estaba.
50. El OAuth dentro de la TWA de Android abre Custom Tab y regresa a la app con sesión, sin quedarse en Chrome.
51. El OAuth en la PWA instalada en iOS (standalone) regresa a la app con sesión, sin quedarse atorado en Safari.
52. Los componentes de Clerk usan appearance con colores, radios y tipografía de marca; 0 azules/morados por defecto de Clerk.
53. Los componentes de Clerk están en español (localización es-MX); 0 textos en inglés en todo el flujo de acceso.
54. Producción usa la instancia de producción de Clerk (pk_live_ en el código fuente de la página, no pk_test_).
55. Editar nombre, foto o bio se refleja en header, perfil y tarjetas en ≤5 s sin recargar.
56. El medidor de perfil cuenta como completa la foto del proveedor o la subida; subir foto sube el porcentaje de inmediato. [Regresión]
57. El medidor de perfil dice exactamente qué falta ("Agrega tu bio") y cada pendiente lleva a su campo con un toque.
58. El medidor llega a 100% al llenar todos los campos requeridos (probado llenándolos uno por uno).
59. "Eliminar mi cuenta" está dentro de la app a ≤3 toques desde Ajustes.
60. Eliminar la cuenta exige confirmación en dos pasos y explica qué se borra y en cuánto tiempo.
61. Tras eliminar la cuenta: la sesión se cierra, el perfil público da 404 y los datos se borran de BD y Clerk en el plazo publicado (≤30 días).
62. Existe una URL web pública para solicitar el borrado de cuenta sin tener la app instalada.
63. El usuario puede exportar sus datos o solicitarlo por un canal documentado con respuesta en ≤30 días.
64. Un usuario nuevo tiene rol "usuario"; nunca queda como admin por registrarse.
65. El rol admin solo se asigna desde servidor (publicMetadata/BD) y no se puede cambiar desde el cliente.

## 3. Navegación y rutas

66. La tab bar inferior en celular tiene de 3 a 5 destinos, cada uno con ícono y texto.
67. Cada destino de la tab bar mide ≥44×44 px y la barra respeta env(safe-area-inset-bottom).
68. La pestaña activa se distingue por color de marca y además por relleno o peso, no solo por color.
69. La tab bar no tapa contenido: el último elemento de cada pantalla es visible completo al llegar al fondo.
70. La tab bar no brinca ni queda sobre el teclado al escribir en iOS/Android (se oculta o se queda abajo).
71. En ≥1024 px la navegación es header o sidebar; no se ve la tab bar móvil estirada.
72. El atrás de Android/navegador regresa a la pantalla lógica anterior; nunca saca de la app desde una pantalla interna.
73. El atrás de Android en la raíz de la TWA cierra la app sin bucles de redirección.
74. Toda pantalla interna tiene botón atrás arriba a la izquierda de ≥44×44 px.
75. Con un modal abierto, el botón atrás cierra el modal en lugar de cambiar de página.
76. Perfiles y proyectos tienen URL estable y compartible (/u/[slug], /p/[slug]) que abre directo el contenido.
77. Los deep links abren la TWA instalada (probar con adb shell am start -a android.intent.action.VIEW -d <URL>).
78. Un deep link a contenido privado sin sesión pasa por login y termina en ese contenido, no en la home.
79. La 404 es de marca, en español, con botón a inicio y responde HTTP 404 real (no 200).
80. Existen error.tsx y global-error.tsx de marca con botón "Reintentar".
81. Un slug o id inexistente devuelve 404 (notFound()), no pantalla vacía ni crash.
82. Un crawler de enlaces (linkinator o similar) sobre producción reporta 0 enlaces internos rotos.
83. Redirecciones permanentes usan 301/308 y ninguna cadena tiene más de 1 salto.
84. No hay bucles entre /sign-in, /onboarding y el inicio (probado con usuario nuevo, existente y sin perfil).
85. http→https y www↔dominio canónico se resuelven en un solo salto.
86. Las rutas protegidas se validan en el middleware del servidor: abrir la URL directo sin sesión redirige a login.
87. /admin devuelve 403 o 404 a quien no es admin, validado en servidor.
88. Al volver atrás a una lista (feed, búsqueda) se restaura la posición de scroll.
89. Filtros y búsqueda viven en la URL (query params) y sobreviven a recargar y compartir.
90. Cambiar entre pestañas principales responde en ≤100 ms (prefetch de Link activo).
91. Los enlaces externos llevan rel="noopener noreferrer" y en la TWA no rompen la sesión de la app.
92. Rutas de prueba (/test, /demo, /playground, /api/debug) responden 404 en producción.

## 4. Layout y responsive

93. En 375 px no hay scroll horizontal: document.documentElement.scrollWidth === clientWidth en todas las rutas. [Regresión]
94. La misma prueba de scrollWidth pasa en 320, 390, 414 y 430 px.
95. En iPhone Safari real, arrastrar la página hacia los lados no la desplaza en ninguna ruta. [Regresión] (página que se corre de lado)
96. html y body tienen overflow-x: clip como red de seguridad sin romper position: sticky.
97. Ningún elemento usa width: 100vw (desborda con scrollbar); se usa 100%.
98. Textos largos sin espacios (URLs, correos) usan overflow-wrap: anywhere y no desbordan.
99. Tablas anchas en celular hacen scroll dentro de su contenedor, no de la página.
100. Hay capturas sin solapes ni cortes en 375×812, 390×844, 430×932, 768×1024, 1024×768, 1440×900 y 1920×1080.
101. En 1440 y 1920 el contenido tiene ancho máximo (1200–1440 px) centrado, no se estira a todo el ancho.
102. En escritorio el layout usa columnas (rejilla de 3–4 tarjetas); no es la columna móvil de 400 px con márgenes enormes.
103. En 768 px hay un layout intermedio: ni el de celular estirado ni el de escritorio apretado.
104. Margen lateral mínimo de 16 px en celular; el contenido nunca toca el borde.
105. Meta viewport: width=device-width, initial-scale=1, viewport-fit=cover; sin maximum-scale=1 ni user-scalable=no.
106. Header y tab bar respetan safe-area-inset-top/bottom; nada queda bajo el notch o la Dynamic Island (captura en iPhone 15).
107. En horizontal en iPhone se respetan safe-area-inset-left/right.
108. Las alturas de pantalla completa usan dvh/svh; ninguna sección de 100vh queda cortada por la barra de Safari.
109. Con el teclado abierto, el input enfocado queda visible encima del teclado (iOS y Android).
110. Los botones fijos inferiores (Enviar, Guardar) quedan sobre el teclado o se ocultan, nunca tapados.
111. En el chat, el input queda pegado al teclado y el último mensaje visible al abrirlo.
112. Los modales en celular son hoja inferior o pantalla completa, con altura máxima 90dvh y scroll interno.
113. Los modales en escritorio miden ≤560 px de ancho y se cierran con Esc y clic fuera.
114. Ningún elemento fijo (incluido el banner de cookies) tapa controles sin espacio compensado.
115. El espaciado sigue una escala de 4/8 px; no hay valores sueltos (13 px, 27 px) en componentes.
116. El z-index sigue una escala documentada; ningún menú desplegable queda detrás de otro elemento.
117. Zoom del navegador al 200% en escritorio no genera scroll horizontal ni rompe el layout (WCAG 1.4.10).
118. En 320×568 (iPhone SE) todos los botones principales son alcanzables y ningún texto se corta.
119. Girar el celular a horizontal no rompe la app (o el manifest fija portrait a propósito).
120. Los avatares son círculos 1:1 en todos los tamaños (aspect-ratio: 1 y object-fit: cover).
121. Ningún texto se encima con otro en ninguna de las 7 resoluciones de referencia.

## 5. Scroll y gestos

122. La rueda del mouse hace scroll vertical en todas las páginas en Chrome, Safari, Firefox y Edge de escritorio. [Regresión]
123. Ningún contenedor con overflow se come la rueda sin poder desplazarse (no hay body/main con height: 100vh + overflow: hidden).
124. Con el cursor encima de un riel horizontal, la rueda vertical sigue bajando la página.
125. El trackpad de Mac desplaza en vertical la página y en horizontal los rieles.
126. En escritorio, los rieles tienen flechas ← → visibles y funcionales (la rueda no los mueve de lado).
127. Los rieles usan scroll-snap y asoman ≥16 px del siguiente elemento para indicar que hay más.
128. Ningún riel repite el mismo primer elemento que otro riel de la misma pantalla. [Regresión] Prueba: listar el primer id de cada riel; todos distintos.
129. Un mismo riel no contiene un elemento dos veces (ids únicos).
130. Cada riel muestra solo lo que dice su título: "Buscan inversión" solo trae proyectos con búsqueda de inversión activa y monto > 0; con 0 resultados el riel se oculta. [Regresión]
131. Un riel con menos de 2 elementos se oculta o muestra un estado vacío intencional.
132. El scroll con inercia funciona en iOS en todos los contenedores con overflow.
133. Modales, drawers y chat usan overscroll-behavior: contain; el scroll no pasa a la página de fondo.
134. Con un modal abierto el fondo no se mueve y al cerrarlo se restaura la posición exacta.
135. El pull-to-refresh del navegador no recarga la app a media conversación o formulario.
136. Deslizar un riel en iOS no dispara por accidente el gesto de "atrás" de Safari.
137. Los carruseles automáticos se pausan al tocarlos y respetan prefers-reduced-motion.
138. El scroll infinito o "Cargar más" pide la siguiente página a ~300 px del final sin duplicar ítems.
139. Listas de más de 200 ítems usan paginación o virtualización y el scroll se mantiene ≥50 fps.
140. Los anclas (#seccion) dejan el título visible bajo el header fijo (scroll-margin-top).
141. touch-action: manipulation en controles evita zoom por doble toque sin bloquear el pellizco.
142. Todo gesto de deslizar (borrar, archivar) tiene alternativa con botón visible.

## 6. Tipografía

143. Solo se usan las 1–2 familias de la marca, cargadas con next/font; ninguna fuente del sistema aparece por error en capturas.
144. El texto de cuerpo mide 16 px en celular y nunca menos de 14 px (12 px solo metadatos).
145. Los inputs miden ≥16 px en celular para que iOS no haga zoom al enfocarlos.
146. En escritorio el H1 mide ≤64 px medido en 1920 px; ningún texto crece sin límite con vw. [Regresión] (letras gigantes)
147. Todo tamaño fluido usa clamp() con máximo definido.
148. La escala tipográfica tiene ≤7 tamaños y no hay tamaños fuera de ella.
149. Interlineado de 1.4–1.6 en cuerpo y 1.1–1.3 en títulos.
150. Los párrafos en escritorio tienen ≤75 caracteres por línea (max-width ~65ch).
151. Los títulos largos en celular hacen salto de línea sin desbordar (text-wrap: balance).
152. Los textos truncados usan elipsis con line-clamp y el texto completo está disponible en el detalle.
153. No hay párrafos en MAYÚSCULAS; solo etiquetas cortas con letter-spacing ≥0.04em.
154. Se usan como máximo 3 pesos de fuente.
155. Precios, tablas y contadores usan tabular-nums.
156. La fuente dibuja acentos, ñ, ¿ y ¡ sin glifos de respaldo (probar "¿Pingüino en Ñuñoa?").
157. El tamaño base está en rem; subir el tamaño de letra del sistema/navegador agranda el texto.
158. Se precargan ≤2 archivos woff2 críticos; ninguna fuente sin usar se descarga.
159. No hay texto de interfaz (títulos, botones) metido dentro de imágenes.
160. Cada pantalla tiene un solo H1 y los niveles H1>H2>H3 no se saltan.

## 7. Color y marca

161. Todos los colores del CSS compilado pertenecen a la paleta cerrada: un script que extrae hex/rgb/hsl de .next/static no encuentra ninguno fuera de la lista.
162. 0 verdes genéricos de éxito (green-*, #22c55e, #16a34a) si no están en la paleta; el éxito usa el color de marca asignado. [Regresión]
163. 0 azules por defecto en pestañas, enlaces o foco (blue-*, #3b82f6, -webkit-link) si no son de marca. [Regresión]
164. 0 lilas/violetas en chips, badges o etiquetas (violet-*, purple-*, #a78bfa) si no son de marca. [Regresión]
165. tailwind.config reemplaza theme.colors (no extend) para que no existan clases fuera de paleta.
166. grep del código: 0 clases de color fuera de tokens (bg-green-, text-blue-, bg-purple-, bg-violet-, etc.).
167. Componentes de terceros (Clerk, toasts, selectores de fecha, mapas) usan colores de marca.
168. accent-color de checkboxes, radios y sliders es de marca.
169. ::selection usa color de marca.
170. -webkit-tap-highlight-color es transparente o de marca, no el azul gris por defecto.
171. El anillo de focus-visible es de marca con contraste ≥3:1 contra el fondo.
172. theme-color del meta y del manifest coincide con el color real de la barra superior.
173. Error, advertencia y éxito tienen tonos definidos dentro de la paleta documentada.
174. Si no hay modo oscuro, color-scheme: light está fijado y la app se ve igual con el sistema en oscuro.
175. Con el sistema en oscuro no hay texto negro sobre negro ni inputs blancos con texto blanco.
176. Las sombras son neutras o tintadas de marca, con ≤3 niveles de elevación.
177. Los enlaces visitados no se ven morados por defecto del navegador.
178. Los íconos usan currentColor o colores de marca; ninguno queda negro por defecto sobre fondo oscuro.
179. El logo se usa solo en sus versiones oficiales, con zona de respeto, sin estirar ni recolorear.
180. Todo texto sobre foto lleva velo de la paleta con contraste ≥4.5:1.
181. Los botones deshabilitados usan colores de la paleta y se distinguen claramente de los activos.

## 8. Iconografía e imágenes

182. Se usa un solo set de íconos con el mismo grosor de trazo en toda la app.
183. Los íconos de interfaz miden 20–24 px y no se mezclan tamaños en una misma barra.
184. El favicon es el símbolo simplificado, no el wordmark: legible a 16×16 y 32×32 (captura de la pestaña). [Regresión]
185. Existen favicon.ico (16/32/48), icon.svg y apple-touch-icon de 180×180 sin transparencia.
186. El manifest tiene íconos 192 y 512 "any" y 512 "maskable" con el símbolo dentro del 80% seguro (probado en maskable.app).
187. El ícono maskable no muestra bordes blancos ni se corta en círculo o squircle en Android.
188. Todas las imágenes usan next/image con width/height o fill + sizes definido.
189. Imágenes en AVIF/WebP; ninguna imagen de contenido pesa más de 300 KB transferidos en celular.
190. Imágenes arriba del pliegue con priority/fetchpriority="high"; las demás con loading="lazy".
191. Toda imagen tiene alt descriptivo en español; las decorativas alt="".
192. No hay línea negra ni blanca en los bordes de imágenes: contenedor con aspect-ratio fijo + object-fit: cover; revisado con zoom en las 7 resoluciones. [Regresión]
193. Las imágenes con object-fit: contain tienen fondo de marca intencional, no negro por defecto.
194. Las portadas de proyectos están hechas para celular; no son una web de escritorio encogida. [Regresión]
195. Si una portada tiene texto, se lee a 375 px (≥12 px efectivos); si no, la portada no lleva texto.
196. Las proporciones son consistentes: 16:9 en tarjetas de proyecto y 1:1 en avatares en toda la app.
197. Las fotos subidas se redimensionan en servidor (≤2048 px de lado) y se les quita EXIF, incluido GPS.
198. Las fotos subidas respetan la orientación EXIF (no aparecen giradas).
199. Las imágenes muestran placeholder (blur o color de marca) del mismo tamaño mientras cargan.
200. Una imagen rota muestra un fallback de marca, nunca el ícono roto del navegador.
201. Los avatares se piden a ≥2x del tamaño mostrado y no se ven pixelados.
202. Las ilustraciones de estados vacíos siguen el estilo y colores de la marca.
203. Las capturas publicadas (web, tienda, redes) no muestran correos, teléfonos, notificaciones, pestañas ni datos de clientes. [Regresión]
204. next.config tiene remotePatterns explícitos, sin comodín "**".
205. Los íconos con significado tienen aria-label y los que acompañan texto aria-hidden="true".

## 9. Formularios y validación

206. Cada input tiene <label> visible asociado; el placeholder no sustituye al label.
207. Cada input usa el type correcto (email, tel, url, number) para mostrar el teclado adecuado.
208. Códigos y montos usan inputmode="numeric"; autocomplete correcto en nombre, correo, teléfono y dirección.
209. Los campos opcionales se marcan "(opcional)" de forma consistente.
210. La validación aparece al salir del campo o al enviar, no desde la primera tecla.
211. Los errores aparecen bajo el campo, en español, y dicen cómo arreglarlo ("El correo necesita una @").
212. Al enviar con errores, el foco va al primer campo con error y se anuncia al lector de pantalla.
213. La validación se repite en servidor (zod en server action/API); un request manipulado no guarda datos inválidos.
214. El botón de enviar se deshabilita y muestra progreso durante el envío.
215. Doble clic rápido en enviar crea 1 solo registro (probado).
216. Un envío exitoso muestra confirmación visible y limpia o redirige el formulario.
217. Si el envío falla por red, lo escrito se conserva y hay botón "Reintentar".
218. Los formularios largos guardan borrador local y ofrecen recuperarlo al recargar.
219. Salir de un formulario con cambios sin guardar pide confirmación.
220. Los límites de caracteres muestran contador ("120/280") y se aplican también en servidor.
221. Los montos aceptan "1,500" y "1500", se guardan como entero (centavos) y se muestran "$1,500 MXN".
222. Los teléfonos aceptan 10 dígitos mexicanos con +52 prellenado.
223. Las fechas se capturan con selector accesible y se muestran dd/mm/aaaa.
224. La subida de archivos indica tipos y peso máximo, muestra progreso y previsualización.
225. Archivos con tipo o peso no permitido se rechazan en cliente y servidor con mensaje claro.
226. La subida de fotos permite recortar a la proporción final (1:1 avatar, 16:9 portada).
227. Las contraseñas tienen botón mostrar/ocultar y permiten pegar.
228. En el chat de escritorio Enter envía y Shift+Enter hace salto de línea.
229. Los formularios funcionan con el autocompletado del navegador y gestores de contraseñas.
230. Ningún formulario pide datos que la app no usa.
231. Checkboxes y radios tienen área táctil ≥44×44 px incluyendo su etiqueta.

## 10. Estados (vacío, carga, error, sin conexión, éxito)

232. Cada lista (proyectos, perfiles, mensajes, notificaciones, guardados) tiene estado vacío con ícono, explicación y CTA.
233. Búsqueda sin resultados muestra "No encontramos resultados para 'X'" y una sugerencia.
234. Las listas y tarjetas cargan con skeletons con la forma del contenido final, no spinner a pantalla completa.
235. Los skeletons ocupan el mismo tamaño que el contenido final (sin salto al llegar los datos).
236. Ningún error muestra "Error: undefined", stack traces ni JSON crudo; siempre mensaje humano y "Reintentar".
237. Los 500 de la API devuelven mensaje genérico al cliente; el detalle solo va al monitoreo.
238. Sin conexión aparece el aviso "Sin conexión" en ≤2 s (probar con DevTools offline y modo avión).
239. Sin conexión, las pantallas ya visitadas cargan desde caché y las demás muestran la página offline de marca.
240. Al volver la conexión, el aviso desaparece y los datos se refrescan solos.
241. Un mensaje escrito sin conexión queda "pendiente" o avisa que no se envió; nunca se pierde en silencio.
242. Los toasts de éxito duran ≥2 s y no requieren cerrarse a mano.
243. Perfiles sin foto o proyectos sin portada se ven intencionales con placeholder de marca.
244. Contenido borrado o suspendido muestra "Este contenido ya no está disponible".
245. Un usuario eliminado aparece como "Usuario eliminado" en conversaciones sin romper el hilo.
246. Al llegar a un límite (plan, cuota) se explica el límite y qué hacer.
247. Un permiso denegado (cámara, notificaciones) explica cómo reactivarlo en ajustes del sistema.
248. Al cambiar de cuenta nunca se ven, ni por un instante, datos de la cuenta anterior.
249. Los contadores de no leídos bajan al leer y nunca muestran negativos ni "NaN".
250. Nunca se muestra "null", "undefined", "NaN", "[object Object]" ni "Invalid Date"; los vacíos se ven como "—" o se ocultan.
251. Un error en un componente queda aislado por error boundary; el resto de la página sigue usable.
252. Existe una página de mantenimiento de marca activable con un flag sin redeploy.
253. Cada estado (vacío, error de API, 3G lenta, offline) se forzó y tiene captura revisada.

## 11. Feedback y microinteracciones

254. Todo elemento tocable cambia visualmente en ≤100 ms al presionarlo (:active).
255. Los botones tienen estados active, focus-visible y disabled; el hover solo dentro de @media (hover: hover).
256. En touch no quedan estados hover pegados después de tocar.
257. Borrar o bloquear pide confirmación o permite deshacer durante ≥5 s.
258. Los toasts salen siempre en la misma posición, no tapan tab bar ni botón de enviar y se pueden cerrar.
259. Las acciones optimistas (me gusta, guardar) cambian al instante y se revierten con aviso si falla el servidor.
260. Las animaciones duran 150–300 ms y ninguna bloquea la interacción más de 400 ms.
261. Con prefers-reduced-motion: reduce se apagan parallax, autoplay y animaciones grandes.
262. Las animaciones solo usan transform y opacity para sostener 60 fps.
263. Copiar al portapapeles muestra "Copiado".
264. Compartir usa navigator.share en celular y copia el enlace en escritorio.
265. Cada mensaje del chat muestra su estado: enviando, enviado o error con reintentar.
266. Los guardados automáticos muestran "Guardado" con hora o check.
267. Los flujos de varios pasos indican "Paso 2 de 3".
268. Los botones cambian su texto durante la acción ("Publicando…"), no solo un spinner sin texto.
269. Todo lo que parece tocable (tarjeta, avatar, chip) es tocable y lleva a algún lado.

## 12. Accesibilidad (WCAG 2.2 AA)

270. Texto normal con contraste ≥4.5:1 y texto grande ≥3:1; axe sin violaciones de contraste.
271. Bordes de inputs e íconos informativos con contraste ≥3:1.
272. Lighthouse Accesibilidad ≥95 en home, perfil, proyecto, mensajes y ajustes.
273. axe-core reporta 0 violaciones críticas o serias en las rutas principales.
274. Objetivos táctiles ≥44×44 px con separación ≥8 px.
275. Toda la app funciona solo con teclado (Tab, Shift+Tab, Enter, Espacio, Esc) sin trampas de foco.
276. El foco siempre es visible (contorno ≥2 px); nunca outline: none sin reemplazo.
277. El primer elemento enfocable es "Saltar al contenido".
278. Los modales atrapan el foco, lo regresan al botón que los abrió y tienen role="dialog" y aria-modal="true".
279. <html lang="es-MX">.
280. Cada página tiene header, nav, un solo main y footer.
281. Los botones son <button> y los enlaces <a href>; ningún div con onClick sin role ni tabindex.
282. Los botones de solo ícono tienen aria-label en español ("Cerrar", "Enviar mensaje").
283. Ninguna información depende solo del color (errores con ícono y texto).
284. Toasts, errores y mensajes nuevos se anuncian con aria-live.
285. Con VoiceOver y TalkBack el login se completa y la home y un perfil se leen en orden lógico.
286. Los errores de formulario usan aria-describedby y aria-invalid.
287. Los videos con voz tienen subtítulos en español.
288. Nada parpadea más de 3 veces por segundo.
289. El pellizco para hacer zoom funciona en celular.
290. Rieles y carruseles se operan con teclado y lector (botones anterior/siguiente etiquetados).
291. El orden del DOM coincide con el orden visual.
292. Los tiempos límite avisan antes de expirar o permiten extender.
293. Toggles, pestañas y acordeones usan aria-pressed, aria-selected o aria-expanded correctos.
294. Ningún enlace dice solo "clic aquí" o "ver más" sin contexto accesible.

## 13. Rendimiento

295. LCP ≤2.5 s en p75 móvil (Speed Insights/CrUX) en home, perfil y proyecto.
296. CLS ≤0.1 en p75 en todas las rutas.
297. INP ≤200 ms en p75.
298. TTFB ≤800 ms en p75.
299. Lighthouse móvil Performance ≥90 en la home.
300. JS inicial de la home ≤200 KB gzip (bundle analyzer).
301. Ningún chunk individual pesa más de 250 KB gzip.
302. La home pesa ≤1.5 MB transferidos en la primera visita en celular.
303. Videos de fondo ≤3 MB, ≤1080p, H.264 + WebM, con preload="metadata" o "none" en celular.
304. Mapas, editores, gráficas y selectores de emoji se cargan con dynamic import solo donde se usan.
305. Scripts de terceros usan next/script con afterInteractive o lazyOnload.
306. Las páginas principales obtienen datos en servidor en paralelo, sin cascadas de fetch en cliente.
307. Ninguna consulta de listado tarda más de 200 ms (logs o EXPLAIN; índices en columnas filtradas).
308. Ningún listado hace consultas N+1 (contar queries por request).
309. Las APIs de listas paginan en servidor con ≤30 ítems por página.
310. Las respuestas de listas típicas pesan ≤100 KB y no incluyen campos innecesarios.
311. Los assets con hash tienen Cache-Control: public, max-age=31536000, immutable.
312. Las páginas públicas que no dependen del usuario usan ISR/revalidate.
313. Durante la carga no hay tareas largas de más de 50 ms bloqueando la interacción principal.
314. Con CPU 4x más lenta, el scroll es fluido y los toques responden en ≤200 ms.
315. 0 console.log de depuración en producción.
316. Lighthouse no marca "Properly size images" en ninguna ruta principal.

## 14. PWA y empaque (manifest, íconos, SW, TWA)

317. /manifest.webmanifest responde 200 con content-type application/manifest+json.
318. El manifest tiene id, name, short_name (≤12 caracteres), description, start_url, scope, display: standalone, background_color, theme_color y lang: es-MX.
319. El short_name no se corta bajo el ícono en Android ni iOS (captura del escritorio del celular).
320. start_url lleva un parámetro de origen (?source=pwa) para medir aperturas instaladas.
321. El manifest incluye screenshots con form_factor narrow y wide.
322. Chrome Android y escritorio permiten instalar sin advertencias (DevTools > Application > Manifest).
323. El service worker está registrado con scope "/" y sin errores en DevTools.
324. El SW nunca cachea respuestas autenticadas o de /api con datos privados.
325. El SW usa network-first para HTML y cache-first o stale-while-revalidate para assets con hash.
326. Tras un deploy, el usuario recibe la versión nueva en ≤1 recarga o ve "Hay una nueva versión, actualizar".
327. Nadie se queda atorado en una versión vieja: desplegar dos veces seguidas y confirmar que el SW se actualiza.
328. La página offline de marca está precacheada.
329. En standalone no hay barras de navegador y el header respeta la barra de estado.
330. En iOS existen apple-mobile-web-app-capable, apple-mobile-web-app-status-bar-style y apple-touch-icon.
331. En iOS hay apple-touch-startup-image para los iPhone vigentes o el arranque es del color de marca sin blanco.
332. El botón propio de instalar (beforeinstallprompt) solo aparece si la app no está instalada y desaparece al instalar.
333. En iOS se muestran instrucciones "Compartir > Agregar a inicio" en vez de un botón que no hace nada.
334. /.well-known/assetlinks.json responde 200, application/json, sin redirecciones, con package_name y el SHA-256 de la llave de Play App Signing.
335. La TWA instalada desde la prueba interna de Play abre sin barra de URL (Digital Asset Links verificado).
336. La TWA apunta al mismo host de producción y tiene fallback a Custom Tab.
337. La barra de estado y la de navegación de Android en la TWA usan colores de marca.
338. Cada subida a Play incrementa versionCode y usa un versionName legible (1.2.0).
339. El keystore y sus contraseñas están respaldados en un gestor seguro fuera de la laptop.
340. targetSdkVersion cumple el mínimo vigente de Google Play.
341. Tras "Borrar datos" de la app en Android, el primer arranque funciona limpio.

## 15. Notificaciones y permisos

342. El permiso de notificaciones no se pide al cargar; se pide tras una acción relacionada, con pantalla previa que explica el beneficio.
343. Si el usuario rechaza la pantalla previa, no se le vuelve a preguntar en ≥7 días.
344. Las push llegan en ≤10 s en Android (TWA/Chrome) y en iOS 16.4+ con la PWA instalada.
345. Cada notificación tiene título y texto útil en español, ícono de marca y badge monocromático de 96 px.
346. Tocar una notificación abre la pantalla exacta (conversación o proyecto), no la home.
347. El usuario no recibe notificaciones de sus propias acciones.
348. La misma notificación no llega dos veces al mismo dispositivo (uso de tag).
349. Hay preferencias de notificación por tipo (mensajes, proyectos, marketing) y el servidor las respeta.
350. Las notificaciones de marketing están apagadas por defecto.
351. Al cerrar sesión, ese dispositivo deja de recibir push de esa cuenta.
352. Las suscripciones push que responden 404/410 se borran de la BD.
353. Los correos transaccionales pasan SPF, DKIM y DMARC y llegan a bandeja principal de Gmail.
354. Los correos no transaccionales tienen enlace de baja y remitente de marca.
355. Cámara, galería y ubicación se piden solo al usarse y con explicación previa.
356. Rechazar un permiso no rompe el flujo: hay alternativa (subir archivo en lugar de cámara).
357. El contador en el ícono de la app (Badging API) se actualiza y se limpia al leer.

## 16. Contenido y textos (español MX)

358. 0 textos en inglés visibles en la interfaz, incluidos errores, fechas, Clerk, toasts y placeholders.
359. Se habla de "tú" en toda la app; nunca "usted", voseo ni "vosotros".
360. Vocabulario mexicano: "celular", "computadora", "correo" (no "móvil", "ordenador", "email" en la UI).
361. Ortografía sin errores: acentos (sesión, código, publicación) y signos de apertura ¿ ¡.
362. 0 apariciones de lorem ipsum, "Test", "asdf", "TODO", "Coming soon" o "Juan Pérez" de relleno en el HTML de producción (grep de todas las rutas).
363. Las fechas usan Intl con locale es-MX y zona America/Mexico_City ("24 de septiembre de 2026").
364. Las fechas relativas están en español ("hace 5 min", "ayer") y son correctas cerca de medianoche.
365. Moneda con Intl.NumberFormat('es-MX', {style: 'currency', currency: 'MXN'}); se añade "MXN" donde pueda confundirse con USD.
366. Números grandes abreviados en español y de forma consistente ("1.2 mil", "3.4 M").
367. Plurales correctos ("1 proyecto", "2 proyectos"); nunca "proyecto(s)".
368. Los botones usan verbos específicos ("Publicar proyecto", "Enviar mensaje"), nunca "OK" ni "Submit".
369. Títulos y botones usan mayúscula tipo oración ("Mis proyectos", no "Mis Proyectos").
370. Los mensajes de error no culpan al usuario y siempre ofrecen una salida.
371. El tono de marca está definido en una guía corta y se aplica igual en onboarding, errores y correos.
372. Los textos de usuarios respetan saltos de línea y sus enlaces son clicables con rel="nofollow ugc".
373. Las cifras públicas (usuarios, proyectos, inversión) salen de la BD y son reales, no inventadas.
374. Existe página de contacto con un correo de soporte real que responde.
375. El año del footer es el actual o dinámico.
376. Las secciones de inversión no prometen rendimientos garantizados y llevan aviso de riesgo.

## 17. Privacidad, seguridad y legal

377. Existe Aviso de Privacidad conforme a la LFPDPPP accesible en ≤2 toques desde footer, registro y ajustes.
378. Existen Términos y Condiciones con fecha de actualización, enlazados en el registro.
379. Aviso de privacidad y términos abren como URL pública sin login.
380. El banner de cookies (si hay cookies no esenciales) tiene "Aceptar" y "Rechazar" con el mismo peso visual y la analítica no carga antes de aceptar.
381. Si hay inversión o contenido para adultos, el registro exige confirmar mayoría de edad (18+) y está en los términos.
382. Perfiles, proyectos y mensajes se pueden reportar en ≤2 toques con motivo.
383. Un usuario puede bloquear a otro; el bloqueado no puede escribirle (probado con 2 cuentas).
384. Correo y teléfono de un usuario no son visibles para otros salvo que él lo active.
385. El usuario A no puede leer, editar ni borrar recursos de B cambiando el id en la URL o request (prueba IDOR).
386. Los IDs públicos no son secuenciales (uuid, cuid o slug).
387. Toda server action y API route valida auth() en servidor y nunca confía en un userId enviado por el cliente.
388. 0 secretos (sk_, DATABASE_URL, CLERK_SECRET_KEY) en el bundle del cliente (grep en .next/static).
389. 0 secretos en el repo y su historial (gitleaks o trufflehog sin hallazgos).
390. Headers presentes: Strict-Transport-Security, X-Content-Type-Options: nosniff, Referrer-Policy, frame-ancestors y Permissions-Policy (securityheaders.com ≥A).
391. Content-Security-Policy definida sin 'unsafe-eval' en producción y compatible con Clerk.
392. <script>alert(1)</script> en bio, título y mensaje se muestra como texto plano.
393. Las subidas validan el tipo real por magic bytes y no aceptan SVG de usuarios sin sanitizar.
394. Adjuntos y documentos privados se sirven con URLs firmadas que expiran.
395. Hay rate limiting en APIs y formularios (p. ej. ≤10 mensajes/min por usuario).
396. Las cookies de sesión son Secure, HttpOnly y SameSite=Lax o Strict.
397. Los logs no guardan contraseñas, tokens ni datos personales completos.
398. Capturas privadas, exportaciones de BD y .env no están en /public ni en el repo. [Regresión]
399. Todo archivo en /public está referenciado por la app (lista de archivos del deploy revisada).
400. Existen reglas de comunidad publicadas y enlazadas desde el flujo de reporte.
401. npm audit --omit=dev reporta 0 vulnerabilidades high o critical.
402. Los mensajes privados solo los ven emisor y receptor; el acceso de admins queda registrado.

## 18. Marketplace: perfiles, proyectos y mensajes

403. El perfil público muestra foto, nombre con mayúsculas, titular, bio y proyectos, sin etiquetas vacías ("Bio: ").
404. La URL del perfil usa un slug legible y único; cambiar el nombre no rompe enlaces viejos (redirección).
405. Las tarjetas de proyecto muestran portada, título, dueño, categoría y estado igual en todos los rieles.
406. Cada proyecto aparece solo en secciones cuyo criterio cumple; se verifica con una consulta a BD por sección. [Regresión]
407. Borradores y proyectos ocultos no salen en rieles, búsqueda ni sitemap.
408. La búsqueda ignora acentos y mayúsculas ("diseno" encuentra "Diseño").
409. La búsqueda responde en ≤500 ms con debounce de ~300 ms.
410. Filtros y orden se mantienen al paginar sin ítems repetidos ni saltados.
411. Solo el dueño ve y puede ejecutar editar/borrar su proyecto; por API otro usuario recibe 403.
412. Vistas, interesados y seguidores son reales y no suben al recargar el mismo usuario.
413. Escribir desde un perfil o proyecto abre la conversación existente si ya hay una (sin duplicar hilos).
414. Los mensajes llegan al otro usuario en ≤5 s sin recargar.
415. Los mensajes van en orden cronológico con hora local y separadores por día.
416. Al abrir un chat se ve el último mensaje; cargar historial hacia arriba no brinca la posición.
417. Abrir un hilo marca sus mensajes como leídos y baja el contador.
418. No se puede enviar un mensaje vacío o de solo espacios.
419. Los adjuntos en mensajes muestran previsualización y peso.
420. La bandeja muestra avatar, nombre, último mensaje truncado y hora, ordenada por más reciente.
421. El dueño puede ver su perfil "como público".
422. Categorías y etiquetas salen de una lista controlada, sin duplicados tipo "Tecnologia"/"Tecnología".
423. Los guardados/favoritos se guardan en BD y se ven en todos los dispositivos.
424. Los rangos de montos se validan (mínimo ≤ máximo) y siempre muestran moneda.
425. Los rieles de la home tienen un orden definido (recientes, destacados) y no abren todos con el mismo ítem. [Regresión]

## 19. Admin y moderación

426. /admin solo abre con rol admin validado en servidor; un usuario normal recibe 403/404.
427. El admin busca usuarios por nombre o correo y ve fecha de registro y método de acceso.
428. El admin puede suspender y reactivar; un suspendido no puede entrar ni aparece en listados.
429. El admin ve la cola de reportes con estado y el contenido reportado en contexto.
430. Los reportes tienen un tiempo de atención documentado (≤24 h) y el reportante recibe confirmación.
431. El admin puede ocultar o eliminar proyectos, perfiles y mensajes registrando el motivo.
432. Toda acción de admin queda en un log de auditoría no editable (quién, qué, cuándo).
433. El admin ve métricas básicas: registros por día, proyectos, mensajes y reportes abiertos.
434. Las acciones destructivas de admin piden confirmación y usan borrado lógico.
435. El panel admin funciona en 375 px sin scroll horizontal (tablas convertidas en tarjetas).
436. El admin puede marcar y borrar datos de prueba en bloque (is_test) sin tocar datos reales.
437. El admin puede destacar proyectos para rieles curados sin tocar código.
438. Hay filtro básico de spam y groserías en contenido público y mensajes.
439. Las cuentas nuevas tienen límite anti-spam (p. ej. ≤20 conversaciones nuevas el primer día).
440. El último admin no puede quitarse su propio rol.
441. Las páginas admin tienen noindex y no están en el sitemap.
442. El panel admin enmascara datos personales en listas (correo parcial).
443. Los cambios del admin se ven en la app pública en ≤60 s (revalidación).

## 20. SEO y compartir

444. Cada página pública tiene <title> único de ≤60 caracteres con formato "Página · Marca".
445. Cada página pública tiene meta description única de 120–160 caracteres en español.
446. Home, perfiles y proyectos tienen og:title, og:description, og:image 1200×630, og:url, og:type y og:locale es_MX.
447. Las imágenes OG de perfiles y proyectos se generan con next/og usando foto/portada y colores de marca.
448. Pegar un enlace en WhatsApp muestra imagen, título y descripción correctos (og:image ≤300 KB, probado en WhatsApp real).
449. twitter:card es summary_large_image.
450. Cada página tiene link rel="canonical" absoluto con el dominio de producción.
451. sitemap.xml solo incluye páginas públicas indexables y se actualiza con perfiles y proyectos nuevos.
452. robots.txt bloquea /admin, /api y rutas privadas y enlaza el sitemap.
453. Los deploys de preview (*.vercel.app) responden con X-Robots-Tag: noindex.
454. El JSON-LD (Organization, WebSite y Person/CreativeWork donde aplique) pasa el Rich Results Test.
455. Las páginas públicas muestran su contenido con JavaScript desactivado.
456. Search Console está verificado para el dominio y sin errores críticos de indexación.
457. Perfiles o proyectos privados o eliminados no son indexables (noindex o 404).
458. Las URLs van en minúsculas con guiones y sin ids crudos cuando existe slug.
459. Los enlaces de invitación conservan su parámetro a través del login y el registro.

## 21. Tiendas (Google Play y Apple)

460. Ficha de Play en español (MX): nombre ≤30 caracteres, descripción corta ≤80 y larga sin relleno de palabras clave.
461. Ícono de Play 512×512 PNG de 32 bits sin esquinas redondeadas añadidas.
462. Gráfico destacado de 1024×500 con marca y sin texto pequeño.
463. ≥4 capturas de teléfono 9:16 (≥1080×1920) de la app real con datos plausibles no privados.
464. Las capturas de tienda no muestran notificaciones personales ni datos de clientes reales.
465. La sección Seguridad de los datos de Play coincide con lo que la app realmente recolecta.
466. La clasificación de contenido IARC está completa con respuestas veraces.
467. La ficha enlaza la política de privacidad pública (HTTP 200).
468. Play Console tiene declarada la URL de eliminación de cuenta.
469. Google y Apple reciben una cuenta de prueba sin 2FA con acceso a todas las funciones.
470. Si la cuenta de desarrollador personal es nueva, se hizo prueba cerrada con ≥12 testers durante ≥14 días.
471. El informe previo al lanzamiento de Play no reporta fallas ni problemas graves de accesibilidad.
472. Apple: la app ofrece funciones más allá de un sitio envuelto (push, compartir nativo, cámara) para cumplir la guía 4.2.
473. Apple: si hay login con Google/GitHub se ofrece "Iniciar sesión con Apple" o una alternativa conforme a la guía 4.8 vigente.
474. Apple: capturas en 6.9" (1320×2868) y 6.5", más 13" si se publica para iPad.
475. Apple: las etiquetas de App Privacy coinciden con la Seguridad de los datos de Play.
476. Apple: la eliminación de cuenta está dentro de la app (guía 5.1.1(v)).
477. Apple: la app no menciona Android ni Google Play ni dirige a pagos externos contra la guía 3.1.
478. Ambas tiendas tienen correo y URL de soporte válidos.

## 22. Operación (monitoreo, respaldos, datos, deploy, verificación)

479. Errores de cliente y servidor llegan a un monitor (Sentry o similar) con source maps; un error forzado aparece en el panel en ≤2 min.
480. Hay alertas de picos de errores y caídas que llegan a una persona real (correo, WhatsApp o Slack).
481. Un monitor externo de uptime revisa la home y /api/health cada ≤5 min.
482. /api/health verifica la BD y responde 200 en ≤500 ms.
483. La BD tiene respaldos automáticos (Neon PITR o dump diario) con retención ≥7 días y una restauración probada.
484. 0 datos de prueba públicos en producción: la consulta por nombres "test/prueba/demo/asdf", correos @example.com o is_test=true devuelve 0 filas visibles. [Regresión]
485. Los seeds y scripts demo no pueden correr contra la BD de producción (variables y branch de Neon separados).
486. Preview usa BD y Clerk de desarrollo; producción usa los suyos.
487. Nada queda sin subir: git status limpio y git log origin/main..HEAD vacío antes de declarar terminado. [Regresión]
488. El SHA desplegado en producción en Vercel es el HEAD de main.
489. El build de producción pasa sin errores de TypeScript ni ESLint (sin ignoreBuildErrors).
490. Cada entrega se verifica en la URL de producción con capturas en 390×844 y 1440×900 que alguien abrió, miró y describió. [Regresión]
491. Las capturas de verificación se comparan contra esta lista (layout, colores, textos), no solo se generan.
492. Faltar una variable de entorno de producción falla el build con mensaje claro, no en runtime.
493. Las migraciones de BD están versionadas y se aplican antes del deploy; 0 cambios manuales sin registro.
494. Se puede hacer rollback en ≤5 min promoviendo el deploy anterior en Vercel (documentado).
495. El certificado HTTPS se renueva solo y vence en más de 30 días.
496. Los eventos clave (registro, publicar proyecto, enviar mensaje) se miden en analítica sin datos personales.
497. Los límites de consumo de Vercel, Neon, Clerk y Resend tienen alerta antes del tope.
498. Un smoke test de Playwright recorre login, perfil, crear proyecto y enviar mensaje tras cada deploy.
499. Tras cada deploy se revisan los logs 30 min y no hay 5xx nuevos.
500. Esta lista completa se corre antes de cada subida a tiendas y cada versión mayor.

### 23. Diálogos y hojas (aprendido en Momentum, 25-sep-2026) [Regresión]
501. Ningún ancestro de un diálogo `position: fixed` tiene `transform`, `filter`, `perspective`, `contain: paint|layout` ni `will-change: transform`, tampoco como residuo de una animación con `fill: both`. Prueba: abrir cada diálogo y comprobar que su caja queda dentro del viewport (0 ≤ y < innerHeight) y que `getBoundingClientRect().height` del overlay = innerHeight.
502. Un fondo con `backdrop-filter` no anima opacidad (WebKit deja de pintar a sus hijos); la animación va en la caja interior. Prueba en WebKit: al abrir, la caja tiene `opacity` 1 y al menos un botón visible.
503. No existe ninguna regla `body > *` / `body:has(...) > *` que fije `position`; los portales al body (recortadores, modales del proveedor de auth) conservan `position: fixed` computado.
504. Todo diálogo se cierra con Escape, con su botón Cerrar y tocando el fondo, y devuelve el foco al disparador.
505. Todo diálogo se mide en un barrido automático (`qa/*-dialogos.mjs`) con sesión, en 390 y 1440, antes de subir; un diálogo sin prueba no se sube.

### 24. Promesas y consecuencias (Protocolo de Sanidad, `SANIDAD.md`) [Regresión]
506. Existe `PROMESAS.md` con TODO elemento interactivo de la app (id, pantalla, texto, requiere sesión, promesa, consecuencia, prueba); el corredor falla con `SIN PROMESA` si aparece uno nuevo.
507. Existe `qa/sanidad.mjs` que toca cada elemento interactivo con y sin sesión y no reporta ningún `MUERTO` (sin efecto observable en 1.5 s), `ERROR` (consola o red ≥ 400) ni `FUERA` (diálogo fuera del viewport).
508. Cada acción con consecuencia (guardar, seguir, contactar, reportar, bloquear, publicar, pausar, eliminar) se verifica en el lugar donde vive la consecuencia (otra pantalla, base, correo), no solo en el toast.
509. El corredor corre en modo rápido tras cada deploy y completo cada noche; los resultados quedan en `sanidad_corridas` y se ven en `/admin/sanidad`.
510. Toda corrida 100 % verde se contraprueba rompiendo algo a propósito; cada bug arreglado deja una regresión `R-nnn` con la medición que lo detecta.
