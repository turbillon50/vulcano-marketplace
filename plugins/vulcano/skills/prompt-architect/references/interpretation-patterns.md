# Patrones de interpretación específicos de Luis

Patrones aprendidos del estilo de Luis. Aplicar como reglas de interpretación por defecto.

## Estilo de escritura

- **Texto por voz frecuente** → palabras pegadas, falta de puntuación, transcripciones erróneas
- **Mezcla español/inglés** → "métele el secret", "ya está el deploy"
- **Mexicanismos** → "hermano", "va", "pinches", "me lleva"
- **Profanidades = frustración, NO agresión personal** → no defenderse, ofrecer salida concreta
- **Mensajes cortos** → eso significa "ya entiendes, ejecuta", NO "necesito explicación"
- **Pausas largas** → puede estar atendiendo otra cosa, NO presionar

## Verbos vagos y sus traducciones típicas

| Verbo | Significa |
|---|---|
| "métele" | inyectar/integrar/configurar |
| "pásale" | enviar/forward al otro agente (Code o Dispatch) |
| "arma" | construir desde cero |
| "afina" | optimizar/iterar versión existente |
| "salva" | rescatar proyecto roto sin perder lo que ya hay |
| "tira" | borrar/empezar de cero |
| "haz" | ejecutar inmediatamente, sin confirmar |
| "checa" | verificar status sin tocar nada |

## Sustantivos vagos y desambiguación

| Cuando dice | Probablemente significa |
|---|---|
| "el proyecto" | el último mencionado en la conversación |
| "ese cliente" | el último contexto de cliente mencionado |
| "lo de antes" | la tarea más reciente antes del mensaje actual |
| "aquello que" | usar contexto inmediato anterior |
| "la app" | la app activa en discusión |

## Servicios — interpretación por defecto

| Cuando dice | Asumir |
|---|---|
| "Stripe" | LIVE keys, no test |
| "pagos en México" | Stripe LIVE + Mercado Pago para OXXO/SPEI |
| "auth" | Clerk LIVE con webhooks |
| "DB" | Neon Postgres pooled |
| "storage" | Vercel Blob |
| "emails" | Resend con dominio del proyecto |
| "deploy" | Vercel auto-deploy en push a main |
| "demo" | PWA 3 modos (público/usuario/admin), sin Docker, datos mockeados en memoria, toggle flotante |

## Proyectos y aliases comunes

| Aliases que usa | Proyecto real |
|---|---|
| "v gift", "vgift", "v-gift", "vgif" | `v-gift` (prj_ili7eogJiMeLbTPGt7IdqnyV0rLc) |
| "academia", "baile" | `academiadebaile` |
| "decaciones", "decoraciones" | `decaciones` |
| "credetí", "credit", "crédito" | `hapicredit-api-server` (crede-ti.info) |
| "ruta", "ruta 618" | `v0-ruta-618-app` |
| "castores" | `v0-castores-store-frontend` |
| "hakapoke", "haka", "poke" | `v0-restaurant-pwa` (hakapoke.ink) |
| "lobby", "eternime" | `eternime-lobby` |
| "lu spa", "spa" | `lu-spa` |
| "v tv", "vtv" | `v0-v-tv` |

## Patrones de flujo

### "Generé X en Stitch / Figma / v0 / lovable"
→ Asumir: descargó código crudo, lo subió a GitHub, lo conectó a Vercel. Está listo para que Code transforme en demo PWA. **Activar `demo-pwa-builder`.**

### "Me da error"
→ Asumir: HTTP 500 o build failed. Verificar deploy logs + env vars. NO preguntar "¿qué error?", investigar primero.

### "No funciona"
→ Asumir: la URL del deploy responde mal. Probar con curl + ver env vars + ver build logs.

### "Pásame la key" / "necesito el secret"
→ Asumir: el usuario tiene credenciales en su panel y va a copiarlas. Estar listo para recibir + validar + inyectar.

### "Está al horno" / "me lleva"
→ Frustración. NO preguntar "¿qué pasó?" tres veces. Tomar iniciativa de listar proyectos, buscar el problema y proponer plan.

### "Borra eso"
→ Verificar QUÉ es "eso" antes de borrar. Acción destructiva = confirmar 1 vez, luego ejecutar.

## Contexto técnico que siempre asumir

- Stack default: **Next.js 16 + TypeScript + Tailwind v4 + shadcn/ui**
- Hosting: **Vercel**
- DB: **Neon Postgres + pgvector**
- Auth: **Clerk LIVE**
- Pagos: **Stripe LIVE + Mercado Pago**
- Emails: **Resend**
- Idioma de la app: **español mexicano**
- Idioma de comunicación con Luis: **español casual mexicano**
- Mobile-first siempre
