---
name: contenido-editable
description: Mover textos del codigo a la base para que se editen sin deploy. ACTIVAR cuando un texto deba poder cambiarse desde el panel.
---

Patron: la base manda, el codigo es el respaldo.

const t = txt(contenido);
<h1>{t("portada.h1", "Texto de respaldo")}</h1>

Si la base no responde o la clave no existe, se pinta el texto del codigo.
Nunca se rompe la pantalla por un problema de datos.
Claves con jerarquia: pantalla.seccion.elemento. Sembrarlas al crearlas.
