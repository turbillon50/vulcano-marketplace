---
name: total-supervision
description: Supervision Total de la FABRICA — el modulo MAS IMPORTANTE. Equipo profesional de testers + corrector en LOOP CONTINUO. Une las dos mitades que ya existen: qa-crew (recorre TODA la app en celular 390/768 y escritorio 1440: navegacion, los 3 modos, scroll real, carruseles, imagenes rotas, nav sin overlays, responsive) como PROBADOR, y el reintento dirigido del Nucleo Esferico (/root/forge-labs/, nucleo_v2.py) como CORRECTOR. Loop: recorrer -> detectar fallas -> mandar al corrector -> re-verificar -> repetir HASTA VERDE en ambos tamanos. No para hasta que todo funcione. ACTIVAR cuando el usuario diga "supervisa", "revisa todo", "antes de entregar", "esta lista", "QA total", "supervision", "total-supervision", "ponla a prueba", "no para hasta que jale", "loop de correccion", o al cierre de cualquier build. CUARTO y ultimo modulo del pipeline (context-min -> product-standard -> design-library -> total-supervision).
version: 1.0
agents: [Vulcano, qa-crew, nucleo-esferico]
triggers: [supervisa, revisa todo, antes de entregar, esta lista, QA total, supervision, total-supervision, ponla a prueba, no para hasta que jale, loop de correccion]
---

# total-supervision — Supervision Total (el corazon de la fabrica)

Cuarto y ultimo eslabon. Recibe el producto vestido y NO lo suelta hasta que pasa **verde en movil (390/768) y escritorio (1440)**. Une PROBADOR + CORRECTOR en un loop cerrado.

> Regla de oro: **no para hasta que todo funcione en ambos tamanos.** El verde libera; cualquier rojo regresa al corrector.

---

## Conexion al Brain

```
Relay exec (bash):  POST http://178.105.135.26/brain/exec   body {"secret":"superclaude2025","cmd":"..."}
Relay query (SQL):  POST http://178.105.135.26/brain/query  body {"secret":"superclaude2025","query":"..."}
```
Una sentencia SQL por query. **Relay re-entrante: el Nucleo corre EN Hetzner y NO llama al relay** — los `curl` los dispara el agente, no un script dentro de Hetzner.

---

## LAS DOS MITADES QUE UNE

### Mitad 1 — PROBADOR: `qa-crew`
Skill `/root/.claude/skills/qa-crew/SKILL.md`. La cuadrilla abre la app como humanos y la rompe. Recorre en **390, 768 y 1440**:
- Navegacion completa y los **3 modos** (publico/usuario/admin) con su toggle.
- **Scroll real**, carruseles (touch en movil), pinch-zoom donde aplique.
- **Imagenes rotas**, assets faltantes.
- **Nav sin overlays**: flotantes no tapan navegacion (estandar v3 de design-library).
- Responsive de verdad en los 3 breakpoints.
- Verifica el checklist de **product-standard**: panel admin real + comunicacion usuario<->admin (tiempo real + correo + retro + notas).

### Mitad 2 — CORRECTOR: Nucleo Esferico (`/root/forge-labs/nucleo_v2.py`)
El **reintento dirigido** del nucleo: identifica el gajo culpable, re-pasa el reporte a su instancia Codex, re-edita SOLO ese gajo, re-funde en orden de dependencia (backend->frontend->tests) y re-corre el gate. Max N con backoff. Invariantes: un archivo un dueno, frontera protegida, gate (tecnico + visual) antes de promover. **Corre EN Hetzner, NO llama al relay.**

---

## EL LOOP CONTINUO

```
   +--------------------------------------------------+
   |                                                  |
   v                                                  |
[RECORRER]  qa-crew en 390/768/1440 + checklist       |
   |                                                  |
   v                                                  |
[DETECTAR]  lista de fallas (modo, breakpoint, gajo)  |
   |                                                  |
   |-- todo verde? --SI--> [LIBERAR] -> entrega       |
   |                                                  |
   NO                                                 |
   v                                                  |
[CORREGIR]  nucleo_v2 reintento dirigido al gajo      |
   |         culpable -> re-edita -> re-funde -> gate |
   v                                                  |
[RE-VERIFICAR] -----------------------------------------+
   (repetir hasta verde o agotar N reintentos -> escalar a Luis)
```

Pasos:
1. **Recorrer** con qa-crew en los 3 breakpoints + checklist product-standard.
2. **Detectar**: cada falla se anota con `{modo, breakpoint, archivo/gajo, sintoma}`.
3. Si **todo verde** en 390 Y 768 Y 1440 -> **liberar** (registrar win, entregar).
4. Si hay **rojo** -> mandar al **corrector** (nucleo): apunta el gajo culpable, le pasa el reporte, re-edita solo ese gajo, re-funde, re-corre el gate.
5. **Re-verificar** -> volver al paso 1.
6. Repetir **hasta verde**. Si se agotan N reintentos (backoff), **escalar a Luis** con el reporte exacto en lugar de entregar algo roto.

---

## COMO SE INVOCA CADA MITAD

**qa-crew** (probador) — del lado agente, recorre y produce reporte de fallas. Usa su checklist y los breakpoints 390/768/1440.

**Nucleo** (corrector) — se dispara EN Hetzner (no via relay):
```
cd /root/forge-labs && python3 nucleo_v2.py --proyecto <id> --report <reporte_qa.json> --max-retries N
```
El nucleo lee el reporte, ataca el gajo culpable y re-corre su gate visual (gate_visual.VisualGate) + tecnico. El resultado (verde/rojo) vuelve al loop.

---

## CRITERIO DE VERDE (libera)

- [ ] 3 modos navegables OK en 390, 768 y 1440.
- [ ] Scroll, carruseles y efectos funcionan (touch en movil).
- [ ] Cero imagenes rotas / assets faltantes.
- [ ] Flotantes NO tapan nav (v3).
- [ ] Panel admin real + comunicacion usuario<->admin (tiempo real + correo + retro + notas) — checklist product-standard.
- [ ] Responsive real en los 3 breakpoints.

Solo con TODO verde se libera. Se registra:
```
INSERT INTO lessons (project_id,type,area,lesson,fix,source)
VALUES ('andromeda','win','supervision','loop probador+corrector llevo a verde en 390/768/1440','total-supervision sobre qa-crew + nucleo_v2','total-supervision')
```

---

## HANDOFF / PIPELINE

```
context-min -> product-standard -> design-library -> [total-supervision: loop hasta verde] -> ENTREGA
```

- **Consume** el producto vestido (ficha de diseno + esqueleto + contexto).
- **Orquesta** qa-crew (probador) <-> nucleo_v2 (corrector) en loop.
- **Produce** el producto SUPERVISADO y marca el Brain:
  ```
  UPDATE projects SET phase='supervisado', next_step='entrega', last_agent='total-supervision', blocked=NULL, updated_at=now() WHERE id='andromeda'
  ```
- Si no llega a verde tras N reintentos -> `blocked` con el motivo y escalar a Luis. **Nunca entrega en rojo.**
