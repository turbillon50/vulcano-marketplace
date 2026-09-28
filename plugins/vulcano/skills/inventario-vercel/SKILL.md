---
name: inventario-vercel
description: Inventario y limpieza tipo RepoVision de los proyectos de Vercel. Mapea cada proyecto, identifica cual sirve cada dominio (vivo), detecta duplicados y abandonados, y recomienda que borrar con EVIDENCIA. Borra SOLO con confirmacion explicita del usuario (borrar es irreversible). ACTIVAR cuando Luis diga limpiar, ordenar proyectos, repovision, hay mucho duplicado, dejar limpio Vercel.
---
# Inventario Vercel (RepoVision)
Pasos: 1) list_projects. 2) por proyecto: get_project -> dominios custom + ultimo deploy (READY/ERROR/BLOCKED). 3) clasifica: VIVO (sirve un dominio custom y READY) = se queda; DUPLICADO/ABANDONADO (sin dominio custom, o demo roto) = candidato a borrar. 4) ante duda, abre la URL .vercel.app y mira que es. 5) presenta tabla: vivo / revivir / basura, con evidencia. 6) borra SOLO los confirmados, uno por uno con el OK del usuario, via DELETE /v9/projects/{id}. NUNCA borres el que sirve un dominio en uso. Verifica que las apps vivas sigan cargando tras borrar.
