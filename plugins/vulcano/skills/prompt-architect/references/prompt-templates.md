# Plantillas de prompts óptimos por tipo de tarea

Cada plantilla se llena con datos del contexto interpretado y se pasa a Code o se ejecuta directo.

---

## Plantilla 1 — DEMO PWA (Stitch → demo presentable)

```
CONTEXTO: Repo [NOMBRE_REPO] recién importado de [STITCH/FIGMA/V0/LOVABLE].
Diseñador profesional. Demo para cerrar cliente en 5-10 min.

MISIÓN: Convertir en PWA demo con 3 modos navegables (público/usuario/admin)
+ toggle flotante + datos demo plausibles + animaciones cinematográficas + PWA real.

RESTRICCIONES:
- Stack: Next.js 16 + TS estricto + Tailwind v4 + shadcn/ui + Framer Motion
- Cero Docker, cero DB externa, cero credenciales reales — todo en memoria
- Idioma: español mexicano
- Mobile-first
- Una corrida sin pausar para confirmar

VERTICAL DETECTADO: [VERTICAL]
DATOS DEMO: [N usuarios, N transacciones, 12 meses históricos]

DELIVERABLES: URL preview Vercel + DEMO_SCRIPT.md de 5 min

Aplicar skill `demo-pwa-builder`. Adelante en una corrida.
```

---

## Plantilla 2 — INTEGRACIÓN SERVICIO (Stripe, Reloadly, Hotelbeds, etc.)

```
CONTEXTO: Proyecto [PROYECTO] necesita integrar [SERVICIO].
Credenciales [INYECTADAS_YA / PENDIENTES_DE_USUARIO].

MISIÓN: Integrar [SERVICIO] con:
- Cliente API en /lib/[servicio]/client.ts
- Endpoints en /app/api/[servicio]/*
- UI en /[ruta] con buscador + ficha de detalle
- Webhook en /api/webhooks/[servicio] si aplica
- Manejo de errores premium + loading states

RESTRICCIONES:
- NO romper integraciones existentes
- Reusar design system del proyecto
- Idioma: español mexicano
- TypeScript estricto

DELIVERABLES: PR draft + URL preview Vercel + screenshot de la nueva sección
```

---

## Plantilla 3 — FIX URGENTE (app rota, deploy fallido)

```
CONTEXTO: [URL] devuelve [HTTP_CODE]. Último deploy [DEPLOY_ID].
[N] env vars activas. Causa probable: [CAUSA_DETECTADA].

MISIÓN: Diagnosticar root cause + aplicar fix mínimo + verificar.

RESTRICCIONES:
- Fix quirúrgico, no refactor
- NO tocar features que ya funcionan
- Confirmar con curl HTTP 200 al terminar

DELIVERABLES: commit del fix + URL respondiendo 200 + nota de qué pasó
```

---

## Plantilla 4 — SCHEMA / MIGRACIÓN DB

```
CONTEXTO: DB [NOMBRE_DB] en Neon. Schema en /[ARCHIVO_SQL] commit [HASH].
Estado actual: [N] tablas / vacío.

MISIÓN: Ejecutar schema completo + verificar + sembrar mínimo viable.

RESTRICCIONES:
- NO inventar columnas que no estén en el SQL
- NO borrar datos sin confirmar
- Idempotente (CREATE IF NOT EXISTS donde aplique)

DELIVERABLES: N de M tablas creadas + admin user en DB + URL endpoint /api/health responde 200
```

---

## Plantilla 5 — RESCATE DE PROYECTO (Code está atorado)

```
CONTEXTO: Code llevaba [N] PRs trabajando en [PROYECTO]. Último PR
intentó [QUÉ_INTENTÓ] pero [POR_QUÉ_FALLÓ].

MISIÓN: Identificar qué se puede salvar del trabajo previo + descartar lo que no
funcione + tomar enfoque alternativo que SÍ funcione en Vercel sin [LIMITACIÓN].

RESTRICCIONES:
- NO reescribir desde cero si hay código aprovechable
- NO requerir infra que el usuario no tiene (Docker, servicios pagos no autorizados)
- Una corrida sin pausar

DELIVERABLES: branch nueva con fix + URL preview Vercel funcionando + nota de qué se
salvó vs qué se reemplazó
```

---

## Plantilla 6 — ENVÍO A OTRO AGENTE (Code, Dispatch, otro chat)

Cuando Luis pide "pásale esto a Code":

```
PARA: Claude Code en repo [REPO]
DE: Coordinador de infra (chat de Luis)
PRIORIDAD: [ALTA/MEDIA/BAJA]

CONTEXTO QUE YA TIENES:
- [Estado actual del proyecto]
- [Env vars disponibles]
- [Lo que YA ESTÁ HECHO en sesiones previas]

TAREA NUEVA:
[Una frase clara de qué hacer]

CONSTRAINTS:
[Lo que NO puedes hacer + lo que SÍ debes respetar]

DELIVERABLES ESPERADOS:
1. [Output 1]
2. [Output 2]
3. URL del preview Vercel
```

---

## Cómo seleccionar la plantilla

| Petición de Luis | Plantilla |
|---|---|
| "convierte en demo" / "PWA para vender" | 1 (Demo PWA) |
| "métele Stripe/Reloadly/etc" | 2 (Integración) |
| "no funciona" / "está roto" | 3 (Fix urgente) |
| "ejecuta el schema" / "crea las tablas" | 4 (Schema DB) |
| "Code quemó tokens y no llegó" | 5 (Rescate) |
| "pásale esto a Code" / "manda a Dispatch" | 6 (Envío) |

---

## Reglas universales

Todos los prompts deben:

1. Empezar con CONTEXTO real (no genérico)
2. Tener UNA MISIÓN clara (no listar 5 cosas)
3. Restricciones explícitas (qué NO hacer)
4. Deliverables verificables (no "termina la app")
5. Cero ambigüedad — si hay duda, ejecutar la decisión más conservadora
6. Idioma español mexicano profesional
7. Mencionar que NO se pidan credenciales al usuario
