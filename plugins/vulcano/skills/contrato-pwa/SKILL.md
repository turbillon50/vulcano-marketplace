---
name: contrato-pwa
version: 2.0
description: Template de contrato de prestacion de servicios PWA para All Global Holding LLC / MYMOMENTUM. Adaptar variables entre [[ ]] por proyecto. ACTIVAR cuando el cliente acepte y necesite contrato formal.
triggers:
  - "genera el contrato"
  - "contrato para"
  - "redacta el contrato"
  - "el cliente acepto"
  - "necesito el contrato"
---

# Contrato PWA — Template MYMOMENTUM

## Variables a reemplazar
```
[[CLIENTE_NOMBRE]]     → nombre completo del cliente
[[CLIENTE_TIPO]]       → "persona fisica" o "representante legal de [empresa]"
[[APP_NOMBRE]]         → nombre de la app (ej: MT Empresarial)
[[APP_TAGLINE]]        → slogan de la app
[[APP_DESCRIPCION]]    → descripcion corta del producto
[[CIUDAD]]             → ciudad donde se firma
[[FECHA]]              → fecha de firma
[[MONTO_TOTAL]]        → monto total en MXN (numeros y letra)
[[PAGO_1_MONTO]]       → anticipo a la firma
[[PAGO_2_MONTO]]       → pago por integracion
[[PAGO_3_MONTO]]       → saldo final
[[PAGO_3_PLAZO]]       → plazo para saldo final (ej: "junio 2026")
[[PLAZO_TESTING]]      → dias habiles para entregar testing (default: 15)
[[PLAZO_PRODUCCION]]   → dias habiles para produccion tras aprobar testing (default: 10)

STACK (incluir solo los que apliquen):
[[STACK_DB]]           → "Neon (PostgreSQL serverless)" o alternativa
[[STACK_AUTH]]         → "Clerk" o alternativa
[[STACK_MAPS]]         → "Mapbox" (si aplica)
[[STACK_EMAIL]]        → "Resend" (si aplica)
[[STACK_PAGOS]]        → "Stripe" / "Mercado Pago" / "ambos" (si aplica)
[[STACK_PUSH]]         → "Web Push VAPID" (si aplica)
```

## Modulos estandar por tipo de app
```
PWA Basica:
  - Autenticacion Clerk
  - Base de datos Neon
  - Panel admin
  - Notificaciones Resend
  - Dominio personalizado

PWA + Pagos:
  + Stripe o Mercado Pago
  + Historial de transacciones
  + Reportes descargables

PWA + Mapas:
  + Mapbox trazado de rutas
  + GPS en tiempo real
  + Asignacion de unidades

PWA + Flota/Logistica:
  + Gestion de vehiculos
  + Asignacion de choferes
  + Dispatcher dashboard
  + Reportes de operacion
```

## Pricing estandar MYMOMENTUM
```
PWA Basica (landing + auth + 1 panel):
  MXN  8,000 — 10,000
  50% firma / 50% entrega

PWA Media (3 roles + pagos + mapas):
  MXN 12,000 — 18,000
  40% firma / 20% integracion / 40% entrega

PWA Compleja (flota + admin + integraciones multiples):
  MXN 20,000 — 35,000
  30% firma / 30% testing / 40% produccion

SaaS / Plataforma multi-tenant:
  MXN 40,000+
  Cotizacion especial por alcance
```

## Contrato completo (reemplazar variables)

---
ALL GLOBAL HOLDING LLC · MYMOMENTUM

CONTRATO DE PRESTACION DE SERVICIOS
DESARROLLO DE APLICACION WEB PROGRESIVA (PWA)
"[[APP_NOMBRE]]"
"[[APP_TAGLINE]]"

[[CIUDAD]], Mexico · [[FECHA]]

DECLARACIONES

I. DEL PRESTADOR
LUIS HUMBERTO DE LA TORRE HERRERA, Representante Legal y Obligado Solidario de ALL GLOBAL
HOLDING LLC, sociedad constituida bajo las leyes de Delaware, Estados Unidos de America.
EL PRESTADOR cuenta con capacidad tecnica bajo la linea de producto MYMOMENTUM.

II. DEL CLIENTE
[[CLIENTE_NOMBRE]], [[CLIENTE_TIPO]], en lo sucesivo "EL CLIENTE".

CLAUSULAS

PRIMERA — OBJETO
Desarrollar y entregar "[[APP_NOMBRE]]": [[APP_DESCRIPCION]]

SEGUNDA — ALCANCES
- Dominio personalizado configurado
- Base de datos: [[STACK_DB]]
- Autenticacion: [[STACK_AUTH]]
[SI MAPAS]  - Mapas y rutas: [[STACK_MAPS]]
[SI EMAIL]  - Notificaciones: [[STACK_EMAIL]]
[SI PAGOS]  - Pasarela de pagos: [[STACK_PAGOS]]
[SI PUSH]   - Notificaciones push: [[STACK_PUSH]]
- Panel de administracion completo
- Interfaz responsiva (movil, tablet, escritorio)
- Despliegue en produccion
- Capacitacion inicial

TERCERA — PAGO
Total: [[MONTO_TOTAL]] MXN

1. Anticipo a la firma:       [[PAGO_1_MONTO]] MXN  (a la firma)
2. Pago por integracion:      [[PAGO_2_MONTO]] MXN  (al conectar todo)
3. Saldo final:               [[PAGO_3_MONTO]] MXN  ([[PAGO_3_PLAZO]])

Pago via: Mercado Pago / Transferencia SPEI
CLABE: 722969010740807451
Titular: LUIS HUMBERTO DE LA TORRE HERRERA

CUARTA — PLAZO
- Testing: [[PLAZO_TESTING]] dias habiles desde firma + anticipo
- Produccion: [[PLAZO_PRODUCCION]] dias habiles tras aprobar testing
- Total maximo: [[PLAZO_TESTING + PLAZO_PRODUCCION]] dias habiles
- El plazo se pausa si el retraso es atribuible al cliente.

QUINTA — OBLIGACIONES DEL PRESTADOR
- Calidad y diligencia MYMOMENTUM
- Actualizaciones de avance continuas
- Atencion de bugs en max 48 horas habiles
- Soporte: lunes-sabado 9am-7pm (hora local)

SEXTA — OBLIGACIONES DEL CLIENTE
- Pagos en tiempo y forma
- Proveer informacion y materiales en max 48h
- Un solo punto de contacto para aprobaciones
- Aprobar hitos en max 48h (silencio = aprobacion tacita)

SEPTIMA — PROPIEDAD INTELECTUAL
- El cliente obtiene uso y explotacion comercial al liquidar total
- Garantia: 24 meses de funcionamiento
- Soporte sin costo: 12 meses
- MYMOMENTUM conserva arquitectura base y componentes genericos

OCTAVA — CONFIDENCIALIDAD
Vigencia del contrato + 2 anos.

NOVENA — TERMINACION ANTICIPADA
- Mutuo acuerdo por escrito
- Incumplimiento con 5 dias habiles para subsanar
- Fuerza mayor
En terminacion: prestador conserva pagos recibidos, cliente recibe avance proporcional.

DECIMA — BUENA FE
Resolver diferencias por dialogo antes de instancias formales.

DECIMA PRIMERA — JURISDICCION
Leyes de los Estados Unidos Mexicanos.
Tribunales de [[CIUDAD]], Mexico.

DECIMA SEGUNDA — ACEPTACION
Firman de conformidad en [[CIUDAD]], [[FECHA]].

_______________________________    _______________________________
EL PRESTADOR                        EL CLIENTE
LUIS HUMBERTO DE LA TORRE HERRERA  [[CLIENTE_NOMBRE]]
ALL GLOBAL HOLDING LLC

---

ANEXO TECNICO-FUNCIONAL (adjuntar modulos especificos del proyecto)

---

## README objetivo de esta skill

OBJETIVO FINAL:
Generar un contrato profesional, legalmente solido y adaptado a cualquier
proyecto PWA de MYMOMENTUM en menos de 5 minutos. El contrato debe:
1. Reflejar exactamente lo que se va a entregar (no mas, no menos)
2. Proteger a Luis (pagos escalonados, IP, terminacion)
3. Dar claridad al cliente (plazos, canales, aprobaciones)
4. Ser ejecutable en Mexico y firmable digitalmente

CUANDO USAR:
- Cliente acepto verbalmente o por WhatsApp
- Antes de iniciar cualquier desarrollo
- Al renovar o ampliar alcances

COMO USAR:
1. Identificar tipo de app (basica/media/compleja/SaaS)
2. Llenar variables [[]] segun el proyecto
3. Incluir solo los modulos que apliquen
4. Generar PDF con formato All Global Holding
5. Enviar por WhatsApp/email para firma

RESULTADO: contrato listo para firmar, $$ protegidos.
