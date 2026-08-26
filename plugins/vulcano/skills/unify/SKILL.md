---
name: unify
description: Unificador de inteligencias. Un cerebro (Brain), muchos cuerpos (Claude Code, Grok, Codex, enjambre). Enruta cada job al worker vivo mas barato que lo pueda hacer, con failover cuando Claude se queda sin cuota. ACTIVAR cuando el usuario diga unify, unificador, amalgamar IAs, ruteo, enjambre, ocupar Claude, sin APIs, optimizar cuota, quien hace esto, o cuando haya que decidir entre Claude, Grok y Codex.
metadata:
  type: workflow
  version: "1.0"
  stack: vulcano-vforge
---

# UNIFY

Luis habla con el motor. UNIFY elige el cuerpo.

Doctrina de maestro_boot:
- code / reason / debug -> claude_A si viva
- chat / fast / research -> grok
- complex / swarm -> POST /enjambre/execute
- media -> higgsfield
- Codex quota baja -> Claude o Grok
- Grok prompts max 3000 tokens
- Brain antes y despues
- dispatch aliases claude_code/code/mesh -> claude
- claude_B hoy no_encontrada

Cadenas de failover:
- code: claude_A -> codex -> grok
- reason/debug: claude_A -> grok
- chat/fast/research: grok
- swarm/complex: enjambre

Arranque: maestro_boot, leer enjambre+ruteo_modelos, clasificar, despachar, verificar, brain_note.
Jobs largos: nohup + log. Output Codex/ChatGPT: sanitize_message.
Keys apagadas salvo emergencia. CLIs por suscripcion (Max, SuperGrok, ChatGPT Pro).
