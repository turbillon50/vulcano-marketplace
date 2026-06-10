---
name: skill-factory
description: Meta-skill que convierte automáticamente cualquier tarea nueva o desconocida en una skill reutilizable. ACTIVAR cuando Claude Code no tenga una skill existente para lo que el usuario pide, cuando el usuario diga "no sabes hacer esto", "aprende a hacer esto", "guárdalo como skill", "que esto quede como habilidad", "automatiza esto", o cuando Claude Code detecte que está improvisando un flujo complejo que podría beneficiarse de ser una skill documentada. También activar cuando el usuario diga "skill factory", "nueva habilidad", "crea una skill para esto", o cualquier variante. Esta skill tiene prioridad BAJA — solo se activa cuando NINGUNA otra skill existente cubre la tarea. Si ya existe una skill relevante, usar esa primero.
---

# Skill Factory — Aprende haciendo, guarda para siempre

Cuando te pidan algo que no sabes hacer bien o que no tienes skill para ello, NO improvises ni des vueltas. Conviértelo en skill mientras lo resuelves.

---

## Filosofía

> **Cada problema nuevo es una skill futura. Resuélvelo Y documéntalo en el mismo turno.**

No pedir permiso para crear la skill. No preguntar "¿quieres que lo guarde como skill?". Hacerlo automáticamente si el patrón es reutilizable.

---

## Cuándo se activa

1. **El usuario pide algo y no hay skill que lo cubra** — Detectas que estás improvisando sin guía
2. **Fallaste en algo y lo resolviste** — El fix debería quedar documentado para no repetir
3. **El usuario dice explícitamente** "aprende esto", "guárdalo", "que no se te olvide cómo hacer esto"
4. **Un flujo tomó más de 3 pasos** y es probable que se repita en otro proyecto

## Cuándo NO se activa

- Tareas de un solo paso triviales (crear un archivo, correr un comando)
- Algo que ya tiene skill existente
- Preguntas de conocimiento general
- El usuario dijo que es algo de una sola vez

---

## Proceso (en paralelo con la tarea)

### Paso 1 — Resolver el problema PRIMERO
No detengas la ejecución para documentar. Resuelve lo que el usuario pidió. Mientras lo haces, ve tomando nota mental de:
- Qué pasos seguiste
- Qué decisiones tomaste y por qué
- Qué errores encontraste y cómo los resolviste
- Qué dependencias necesitaste
- Qué era específico de este proyecto vs qué es genérico

### Paso 2 — Evaluar si merece ser skill
Después de resolver, pregúntate:
- ¿Esto se va a repetir en otro proyecto? → SÍ = hacer skill
- ¿Tomó más de 3 pasos no obvios? → SÍ = hacer skill
- ¿Hubo un error/trampa que no era evidente? → SÍ = hacer skill
- ¿Es algo que el usuario tuvo que explicarme? → SÍ = hacer skill
- ¿Es una tarea trivial de un comando? → NO = no hacer skill

### Paso 3 — Generar la skill automáticamente
Crear en `.claude/skills/{nombre-skill}/SKILL.md` con esta estructura:

```markdown
---
name: {nombre-descriptivo}
description: {Qué hace + cuándo activar + triggers}. ACTIVAR cuando {lista de frases trigger}.
---

# {Título}

{Una línea de qué resuelve esta skill}

## Cuándo usar
- {Trigger 1}
- {Trigger 2}

## Reglas
- ✅ {Lo que SÍ hace}
- ❌ {Lo que NO hace}

## Pasos
1. {Paso concreto}
2. {Paso concreto}
3. ...

## Errores conocidos y soluciones
| Error | Causa | Fix |
|---|---|---|
| {error} | {por qué pasa} | {cómo resolverlo} |

## Ejemplo de uso
{Input del usuario} → {Output esperado}
```

### Paso 4 — Informar al usuario
Después de crear la skill, decir brevemente:

> "Creé la skill `{nombre}` para que la próxima vez esto sea automático. Está en `.claude/skills/{nombre}/SKILL.md`."

No explicar el contenido completo de la skill. Solo confirmar que existe.

---

## Reglas para escribir buenas skills

### Descripción (lo más importante)
- La descripción es lo que decide si la skill se activa o no
- Incluir TODAS las frases que el usuario podría decir para trigger
- Ser "pushy" — mejor que se active de más que de menos
- Máximo 3 líneas, pero densas en triggers

### Cuerpo
- Máximo 200 líneas (si necesita más, usar `references/`)
- Pasos concretos, no filosofía
- Incluir la sección de "Errores conocidos" — es el valor real
- Incluir ejemplos de input → output

### NO hacer
- ❌ Skills genéricas tipo "cómo programar en React" — eso ya lo sabes
- ❌ Skills con más de 500 líneas — dividir en skill + references
- ❌ Skills sin triggers claros en la descripción
- ❌ Skills que repiten lo que ya hace otra skill existente

---

## Naming convention

```
{verbo-o-dominio}-{contexto}
```

Ejemplos:
- `setup-clerk-webhooks` (no "clerk-stuff")
- `deploy-vercel-domains` (no "vercel-things")  
- `fix-neon-http-sql` (no "database-helper")
- `generate-pdf-contract` (no "pdf-skill")
- `integrate-reloadly-giftcards` (no "api-integration")

Nombre en inglés, contenido en español mexicano.

---

## Organización de archivos

```
.claude/skills/
├── {skill-name}/
│   ├── SKILL.md              ← Siempre requerido
│   └── references/           ← Solo si necesita docs extra
│       ├── api-examples.md
│       └── error-catalog.md
```

No crear carpetas `scripts/`, `assets/`, `templates/` a menos que realmente se necesiten. La mayoría de skills solo necesitan el SKILL.md.

---

## Mejora continua

Si una skill ya existe pero le falta algo (un error nuevo, un paso que cambió, un trigger que no detecta):

1. **NO crear skill nueva** — editar la existente
2. Agregar el error/paso/trigger a la sección correspondiente
3. Informar: "Actualicé la skill `{nombre}` con {qué agregaste}"

---

## Ejemplo completo

El usuario dice: "Conecta Mercado Pago a este proyecto"

No hay skill para eso. Entonces:

1. **Resuelvo** — Busco docs, configuro OAuth, creo webhook endpoint, inyecto env vars, verifico
2. **Evalúo** — ¿Se repite? Sí, Luis tiene 10+ proyectos. ¿Más de 3 pasos? Sí. → CREAR SKILL
3. **Genero** `.claude/skills/integrate-mercadopago/SKILL.md`:

```markdown
---
name: integrate-mercadopago
description: Integrar Mercado Pago (pagos MX/LATAM) en proyecto Next.js. ACTIVAR cuando el usuario diga "Mercado Pago", "MercadoPago", "pagos México", "cobrar en pesos", "checkout MX", o cuando se necesite procesador de pagos para México/LATAM.
---

# Integrar Mercado Pago

## Pasos
1. Obtener credenciales de MP dashboard (ACCESS_TOKEN, PUBLIC_KEY)
2. Inyectar env vars en Vercel (production + preview + development)
3. Instalar `mercadopago` SDK
4. Crear `/api/mercadopago/create-preference` endpoint
5. Crear `/api/webhooks/mercadopago` para IPN notifications
6. Configurar webhook URL en MP dashboard
7. Verificar con pago de prueba

## Errores conocidos
| Error | Causa | Fix |
|---|---|---|
| 307 redirect en webhook | Vercel trailing slash | Agregar `trailingSlash: false` en next.config |
| `invalid_token` | Token de sandbox vs production | Verificar que ACCESS_TOKEN sea del environment correcto |

## Env vars requeridas
- MERCADOPAGO_ACCESS_TOKEN
- NEXT_PUBLIC_MERCADOPAGO_PUBLIC_KEY
```

4. **Informo**: "Mercado Pago conectado. Creé skill `integrate-mercadopago` para la próxima."

---

## Recordatorio final

**Tu trabajo no es solo resolver. Es resolver Y enseñarte a ti mismo para la próxima.**

Cada proyecto de Luis es una oportunidad de hacer el siguiente más rápido. Las skills son tu memoria muscular.
