---
name: tool-audit
description: Auditoria real de herramientas antes de prometer nada. ACTIVAR al inicio de cualquier corrida de demo/app, cuando un agente diga "no tengo esa herramienta", "no puedo desplegar", "no puedo tomar capturas", "no tengo dominio", o cuando Luis diga "audita tus herramientas", "revisa hetzner", "que si puedes". Verifica CONTRA LA REALIDAD que existan binarios, credenciales, navegador para capturas y dominios, ANTES de declarar un bloqueo o de arrancar un build.
---

# TOOL AUDIT — no declares bloqueo sin auditar

## LEY
Un agente NUNCA dice "no puedo X" sin correr esta auditoria primero.
La sesion de chat tiene POCAS herramientas. El servidor tiene TODAS.
Si te falta algo en la sesion, casi siempre esta en Hetzner.

## ACCESO AL SERVIDOR (fuente de verdad)
POST http://178.105.135.26/brain/exec
body: {"secret":"superclaude2025","cmd":"..."}
Escapa el JSON con python (json.dumps), NO con comillas en bash: se rompe con 400.

Helper canonico:
```python
import json,urllib.request
def run(cmd,timeout=90):
    d=json.dumps({"secret":"superclaude2025","cmd":cmd}).encode()
    r=urllib.request.Request("http://178.105.135.26/brain/exec",data=d,
        headers={"Content-Type":"application/json"})
    j=json.loads(urllib.request.urlopen(r,timeout=timeout).read())
    return j.get("stdout","")+j.get("stderr","")
```

## INVENTARIO CONFIRMADO EN v-forge (2026-08-18)
Binarios: node 18.19.1, npm 9.2.0, git, vercel CLI 54.14, gh CLI, docker, psql,
google-chrome, pnpm, pm2, lighthouse, codex, grok, cerebras-code-mcp.
Capturas: python playwright OK + /root/.cache/ms-playwright (chromium-1223,
headless_shell, webkit). SI se pueden tomar capturas 390/768/1440.
Credenciales en /root/.env (cargar con: set -a; . /root/.env; set +a):
VERCEL_TOKEN, GITHUB_TOKEN, GH_TOKEN, NAMECOM_TOKEN, NEON_API_KEY,
STRIPE_*, RESEND_API_KEY, TWILIO_*, GEMINI_API_KEY, OPENROUTER_API_KEY,
CLERK_* , GOOGLE_MAPS_API_KEY, ELEVENLABS_API_KEY.
Vercel: usuario turbillon50, team luis-projects-48b011f9, 20+ dominios.

## CHECKLIST (correr completo, no a medias)
1. Binarios: node, vercel, gh, google-chrome, playwright.
2. Credenciales: nombres de llave en /root/.env (NUNCA imprimir valores).
3. Vercel vivo: vercel whoami --token "$VERCEL_TOKEN".
4. Dominios: vercel domains ls --token "$VERCEL_TOKEN".
5. Capturas: probar chromium headless real ANTES de prometer QA Gate.

## REGLA DE DOMINIO (resuelve el gate del playbook)
Para demos de cliente NO comprar dominio de arranque. Usar SUBDOMINIO de un
dominio ya propio (ej. cliente.vmomentums.info): es dominio real, es gratis,
es inmediato y cumple "promocion al dominio + verificar sobre el dominio".
Se compra el dominio propio del cliente SOLO cuando el cliente ya dijo que si.
Si se compra: NAMECOM_TOKEN esta disponible.

## SALIDA
Una linea por capacidad: CAPACIDAD -> SI/NO -> evidencia.
Prohibido reportar "no puedo" sin la linea de evidencia correspondiente.
