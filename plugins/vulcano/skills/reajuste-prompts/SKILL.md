---
name: reajuste-prompts
description: Loop de mejora continua de prompts — la biblioteca aprende. ACTIVAR cuando un prompt produzca resultados mediocres, cuando una IA (v0/Claude/Gemini) evalue la calidad de un prompt, cuando Luis diga "mejora el prompt", "reajusta", "prompt perfecto", o al cerrar cualquier build para capturar el prompt ganador.
---
# REAJUSTE DE PROMPTS — el loop que hizo Luis con v0 (8 jun 2026), formalizado

## El loop (probado: asi nacio prompt-frontend-etapa1)
1. EJECUTAR: usar el mejor prompt disponible de la biblioteca.
2. EVALUAR: pedir al mismo agente (u otro) que CALIFIQUE el resultado y el prompt (que salio bajo, que falto, que sobro). v0/Claude lo hacen bien si se les pide explicito.
3. REPROMPTEAR: pedir "dame el prompt PERFECTO corregido" incorporando las fallas detectadas.
4. CAPTURAR: el prompt ganador se guarda en la BIBLIOTECA con fecha, caso de uso y que problema corrige — nunca se queda en el chat.
5. PROPAGAR: actualizar la skill correspondiente en el vault + espejo en brain para que TODOS los agentes usen la version nueva.

## BIBLIOTECA DE PROMPTS (ubicaciones canonicas)
- skills-vault/prompt-frontend-etapa1 — frontend Etapa 1 desde mockups (ganador validado por v0).
- skills-vault/prompt-architect — arquitectura de prompts generales.
- brain_files prompt-* — variantes y ganadores por caso.
Regla: UN ganador por caso de uso; las versiones viejas se reemplazan, no se acumulan.

## Señales de que un prompt necesita reajuste
Resultado generico que ignora el mockup; el agente inventa pantallas/colores; hay que corregir 3+ veces lo mismo; la evaluacion automatica marca rubros bajos.
Relacionado: [prompt-frontend-etapa1], [reprompteo-luis], [vulcano-memoria].