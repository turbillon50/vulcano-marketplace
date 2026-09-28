---
name: vliving-media-ingest
description: Ingesta institucional de fotos de propiedades V&LIVING desde carpetas públicas de Google Drive hacia Hetzner Object Storage, actualización de galería/portada en Neon y QA de producción. Usar cuando Luis entregue una carpeta Drive de una propiedad o desarrollo.
---

# V&LIVING MEDIA INGEST

Objetivo: que Luis pueda pegar en el chat una carpeta pública de Google Drive y EON haga el resto. GitHub NO almacena fotos comerciales.

## Flujo obligatorio
1. Recuperar contexto vigente V&LIVING y confirmar propiedad/proyecto objetivo. No inventar IDs.
2. Verificar que la carpeta Drive sea legible y listar archivos antes de descargar.
3. Descargar en Hetzner a un directorio temporal aislado con `gdown --folder`.
4. Validar archivos: jpeg/png/webp, tamaño > 20 KB, dimensiones mínimas 900 px en lado largo. Rechazar corruptos.
5. Generar derivados WEBP de calidad alta (máx. 1800 px, quality 84) preservando proporción. Nunca sobreescribir originales.
6. Elegir portada por intención comercial, no por orden de archivo: exterior/vista al mar/fachada/terraza/alberca antes que sala. Si Luis define portada, manda su elección.
7. Obtener env de `vliving-2026` de forma local y efímera (`vercel env pull`), chmod 600, jamás imprimir secretos. Borrar env temporal al terminar.
8. Subir con `lib/objeto.js::guardarPublico` a `propiedades/<slug>/` en Hetzner S3. Guardar URLs públicas HTTPS.
9. Actualizar `vl_propiedades.fotos` y la unidad correspondiente en `vl_unidades.fotos` dentro de transacción. La primera URL es portada. No cambiar precios, owner, disponibilidad, fractional, ubicación ni otros campos.
10. Comprobar cada URL: HTTP 200, content-type image/*, dimensiones > 0.
11. Comprobar `https://vliving.site/api/propiedad?id=<id>`: cantidad y orden de fotos correctos.
12. QA navegador 390 px y 1440 px: portada visible, carrusel visible, mapa no roto, sin overflow. Verificar también que `/_next/image` devuelve 200 para la portada.
13. Reportar números: descargadas / válidas / subidas / asignadas, portada elegida y propiedad(es) afectadas.
14. Guardar relevo en Brain.

## Fuente permitida
- Carpeta pública de Google Drive entregada por Luis.
- Directorio local ya existente en Hetzner cuya procedencia esté aprobada.

No usar scraping ni bajar imágenes de portales de terceros salvo autorización explícita.

## Reglas de seguridad
- No imprimir `DATABASE_URL`, S3 keys, ADMIN_KEY ni tokens Vercel.
- No meter binarios al repo Git.
- No cambiar datos comerciales al actualizar galería.
- Antes de UPDATE, SELECT y guardar snapshot JSON de `id,nombre,fotos,actualizada` en `/root/backups/vliving-media/<timestamp>/`.
- UPDATE únicamente IDs explícitamente confirmados.
- Si una imagen falla validación, no publicar esa imagen.
- Si menos de 3 imágenes válidas, no declarar galería terminada.

## Comando de referencia
`/root/skills-vault/vliving-media-ingest/scripts/ingest-drive.sh --drive <URL> --slug <slug> --property-ids <id,id,...> [--cover <filename>]`

La skill debe poder ejecutarse desde cualquier chat con Vulcano/Hetzner sin depender de Claude Code.