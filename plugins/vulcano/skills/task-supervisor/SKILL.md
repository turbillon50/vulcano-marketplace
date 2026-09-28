---
name: task-supervisor
description: Agente supervisor que verifica que las tareas fueron completadas REALMENTE antes de marcarlas como listas. No acepta "parece que funciona" — verifica con evidencia. Si algo falló, regresa y lo completa. ACTIVAR al terminar cualquier tarea de infraestructura o deploy.
---
# Task Supervisor — Verificación real, no supuesta

## Principio
Una tarea no está completa hasta que hay evidencia verificable.
"Lo hice" sin prueba = no lo hice.

## Checklist de verificación por tipo de tarea

### Clerk Production
VERIFICADO cuando:
- [ ] curl -s https://DOMINIO/api/health responde 200
- [ ] dashboard.clerk.com → app → dropdown muestra "Production"
- [ ] pk_live_ en Vercel empieza con pk_live_ (no pk_test_)
- [ ] sk_live_ en Vercel empieza con sk_live_ (no sk_test_)
- [ ] dig CNAME clerk.DOMINIO +short → frontend-api.clerk.services

### DNS Records
VERIFICADO cuando:
- [ ] dig A DOMINIO +short → IP de Vercel (76.76.21.21)
- [ ] dig CNAME www.DOMINIO +short → cname.vercel-dns.com
- [ ] dig TXT resend._domainkey.DOMINIO +short → p=MIGf... (COMPLETO, >100 chars)
- [ ] dig CNAME clerk.DOMINIO +short → frontend-api.clerk.services

### Env Vars Vercel
VERIFICADO cuando:
- [ ] curl Vercel API lista EXACTAMENTE los env vars esperados
- [ ] Cada key tiene el prefijo correcto (pk_live_, sk_live_, whsec_, re_)
- [ ] DATABASE_URL contiene -pooler (no directo)

### Deploy
VERIFICADO cuando:
- [ ] curl -s https://DOMINIO → HTTP 200
- [ ] curl -s https://DOMINIO/api/health → {"status":"ok","db":"up"}
- [ ] No hay errores en Vercel build logs

### Stripe
VERIFICADO cuando:
- [ ] STRIPE_SECRET_KEY empieza sk_live_REDACTED
- [ ] NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY empieza pk_live_REDACTED
- [ ] STRIPE_WEBHOOK_SECRET empieza whsec_
- [ ] curl Stripe API con la key responde 200

## Flujo supervisor

```
Tarea declarada completa
        │
        ▼
¿Hay evidencia verificable? (screenshot, curl, dig)
        │
   NO ──┘──── SÍ
   │                │
   ▼                ▼
Regresar        Registrar en
y completar     skill_runs
        │
        ▼
¿Qué falló exactamente?
        │
        ▼
Ejecutar fix específico
        │
        ▼
Re-verificar desde cero
```

## Comandos de verificación rápida

```bash
# Clerk production
curl -s https://api.clerk.com/v1/instance -H "Authorization: Bearer SK_LIVE" | python3 -c "import sys,json;d=json.load(sys.stdin);print(d.get('environment_type'))"

# Vercel env vars
curl -s -H "Authorization: Bearer VERCEL_TOKEN" "https://api.vercel.com/v10/projects/PID/env?teamId=TEAM" | python3 -c "import sys,json;[print(e['key'],e.get('value','(enc)')[:20]) for e in json.load(sys.stdin).get('envs',[])]"

# DNS completo
for host in "" "www" "clerk" "accounts" "resend._domainkey"; do
  echo -n "$host: "; dig ${host:+$host.}DOMINIO +short | head -1
done

# Health check
curl -sL https://DOMINIO/api/health
```

## Registro de fallos comunes (aprendizaje)
- Clerk "production creado" sin verificar dropdown → task_supervisor detecta pk_test_ en Vercel
- DNS "configurado" sin hacer dig → a veces name.com falla silenciosamente
- Stripe "inyectado" con conflict error → env var ya existía, necesita PATCH no POST
- "Todo listo" sin health check → app puede estar en build fallido

## Integración con skill-eval
Al completar verificación exitosa:
INSERT INTO skill_runs (skill_name, project_id, resultado, que_funciono)
VALUES ('task-supervisor', 'PROYECTO', 'success', 'Verificadas N tareas: lista')

Al detectar fallo y corregir:
INSERT INTO skill_runs (skill_name, project_id, resultado, que_salio_mal)
VALUES ('task-supervisor', 'PROYECTO', 'partial', 'Fallo detectado: descripcion')
