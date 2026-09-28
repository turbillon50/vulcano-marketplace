# LISTA MAESTRA — <APP> — lista maestra del Método
Regla: el agente marca [x] SOLO con evidencia (ruta en producción 200 + captura WebKit mirada, o prueba en verde). `DONE-F1` solo cuando TODO esté en [x] o marcado [LUIS] (le toca a Luis). Vulcano verifica cada [x] y lo desmarca si no se sostiene. Es un loop: al terminar una pasada, vuelve a auditar la app completa y agrega a la lista lo nuevo que encuentres.

## A. Solidez (la app no se desajusta)
- [ ] A1 Nada se corre de lado: 375/390/430, con y sin sesión, tras cambiar pestañas, filtros, atrás/adelante (prueba automática que falla si scrollLeft≠0)
- [ ] A2 Tab bar idéntica en iPhone real y en capturas (íconos + etiquetas)
- [ ] A3 0 errores de consola y 0 respuestas 500 en las 35 rutas (con y sin sesión)
- [ ] A4 Estados vacíos con acción en todas las listas (guardados, mensajes, solicitudes, mis proyectos)
- [ ] A5 Cargas: esqueletos, sin saltos de layout (CLS < 0.1), imágenes con tamaño fijo
- [ ] A6 Offline: página sin conexión y reintento
## B. Cuenta y sesión
- [x] B1 Una persona = una cuenta (Google/GitHub/correo)
- [ ] B2 Registro → salir → entrar por los 3 métodos, probado
- [ ] B3 Cerrar sesión visible (Mi espacio, Tu cuenta, menú) y limpio (caché, SW, atrás)
- [ ] B4 Eliminar cuenta dentro de la app, con confirmación y correo
- [x] B5 /eliminar-cuenta pública (sin sesión)
- [ ] B6 Foto de perfil desde cámara/galería, iniciales naranja sin foto
- [ ] B7 Sesión expirada → aviso claro y vuelta al mismo lugar
## C. Marca y tarjetas
- [ ] C1 Sin verde, azul ni lila (solo naranja y grises; WhatsApp verde solo en su botón)
- [ ] C2 "Profesionistas" en todos lados
- [ ] C3 Rieles sin repetir el primero; "Buscan inversión" solo con inversión
- [ ] C4 Portadas dignas (nada de web encogida), sin línea negra, logos reales o iniciales bien hechas
- [ ] C5 La casa (All Global Holding) no aparece como profesionista
- [ ] C6 Proyectos que buscan usuarios/promotores (campo "qué busca", rieles, acciones)
- [ ] C7 Ticket mínimo comparado en MXN
## D. Contenido de usuarios (políticas de Play: UGC)
- [ ] D1 Reportar proyecto/perfil/mensaje desde donde se ve
- [x] D2 Bloquear usuario funciona
- [ ] D3 Filtro de palabras en textos públicos y mensajes
- [ ] D4 Términos aceptados al registrarse prohíben contenido ofensivo; 18+
- [ ] D5 Respuesta de moderación visible para quien reportó
## E. Panel /admin profesional (solo admin; 404 para los demás)
- [ ] E1 Tablero (usuarios nuevos, publicados, mensajes, reportes, embudo, errores)
- [ ] E2 Usuarios: buscar, ver, verificar, **banear/suspender** y reactivar, cambiar rol, eliminar, "ver como" solo lectura
- [ ] E3 Proyectos: aprobar/rechazar/despublicar, **destacar y ordenar rieles**, editar fichas
- [ ] E4 Moderación: cola de reportes con acciones y motivo, veto por dominio, palabras
- [ ] E5 Contenido: colecciones, novedades, textos de portada
- [ ] E6 Avisos a segmentos (vista previa, conteo, doble confirmación)
- [ ] E7 Bitácora de auditoría de toda acción admin
- [ ] E8 Pruebas de permisos: usuario normal 404 en /admin y /api/admin/*
## F. Legal y soporte
- [x] F1 /legal, /legal/privacidad, /legal/terminos, /legal/aviso, /legal/datos
- [x] F2 /soporte con contacto real
- [ ] F3 Enlaces a todo lo anterior en pie y en Tu cuenta
- [ ] F4 [LUIS] Revisión legal del NDA (hoy BORRADOR)
## G. Empaque Android (TWA)
- [ ] G1 manifest con íconos 192/512 + maskable, nombre, colores, start_url, scope
- [ ] G2 assetlinks.json con el paquete y huella SHA-256 reales
- [ ] G3 Proyecto TWA (Bubblewrap) generado en el servidor y AAB firmado; llave de firma respaldada fuera de git
- [ ] G4 Avisos push funcionan dentro de la TWA
- [ ] G5 Enlaces externos abren fuera sin romper la app; botón atrás de Android correcto
## H. Ficha de Google Play (todo prellenado en STORES-CHECKLIST.md)
- [ ] H1 Ícono 512, gráfico destacado 1024×500, 8 capturas 1080×1920 reales
- [ ] H2 Título, descripción corta y larga en español
- [ ] H3 Cuestionario "Seguridad de los datos" prellenado
- [ ] H4 Clasificación de contenido (cuestionario IARC) prellenado
- [ ] H5 Cuenta de prueba para revisores (zz-revisor, NO se borra, documentada)
- [ ] H6 Política de privacidad URL, soporte URL, eliminación de cuenta URL
- [ ] H7 [LUIS] Cuenta Google Play Console (US$25) y verificación de identidad
- [ ] H8 [LUIS] Subir el AAB a prueba interna → cerrada (Play exige 12 testers 14 días en cuentas personales nuevas; con cuenta de organización no)
## I. Apple (EN PAUSA por Luis)
- [ ] I1 Código de Sign in with Apple listo, sin activar

## S · Sanidad (SANIDAD.md)
- [ ] S1 `PROMESAS.md` completo (0 SIN PROMESA)
- [ ] S2 `qa/sanidad.mjs` con toque de todo, diálogos, estados y R-001…R-010; contraprueba anotada
- [ ] S3 Promesas con consecuencia verificadas de punta a punta con zz
- [ ] S4 Corrida completa 390/1440 con y sin sesión: 0 rojos
- [ ] S5 Rápida tras cada deploy + nocturno + `sanidad_corridas` + `/admin/sanidad`
- [ ] S6 3 noches seguidas en verde antes de tiendas
