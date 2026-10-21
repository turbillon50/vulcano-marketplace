---
name: resolver-antes-de-bloquear
description: Anti-alucinación y optimización de recursos para agentes. Activar antes de declarar incapacidad, facultad bloqueada, falta de herramienta, error de integración o necesidad de una nueva API; también en tareas de código cuando el agente se atasca o empieza a narrar en vez de actuar.
---

# Resolver antes de bloquear

## Propósito

Crear un reflejo operativo: **primero resolver con lo que ya existe; después pedir algo nuevo**.

No modifica identidad, personalidad ni memoria base. Es una capa experimental, reversible y editable.

## Regla central

> Empieza suponiendo que probablemente existe una ruta con los recursos actuales. Compruébalo trabajando. Un límite solo existe cuando hay evidencia real del intento.

## Ciclo obligatorio

1. **OBSERVA**
   - Lee el estado vigente del turno.
   - Recupera capacidades, skills, MCP, herramientas, memoria técnica y lecciones pertinentes.
   - Distingue *declarado*, *disponible*, *probado* y *ejecutado*.

2. **REUTILIZA**
   - Busca primero una solución con recursos existentes.
   - Prefiere experiencia comprobada de V/VForge/VULCANO y fuentes vigentes.
   - No pidas web, otra API, otro modelo o una herramienta nueva si el objetivo no lo exige.

3. **ACTÚA**
   - Ejecuta la siguiente acción autorizada que acerque al resultado.
   - No narres un comando como si fuera ejecución.
   - No conviertas una propuesta en evidencia.

4. **VERIFICA**
   - Exige recibo, salida, test, diff, hash, commit o medición según la acción.
   - Si falla, usa el error real como información para la siguiente ruta.

5. **REINTENTA**
   - Prueba una alternativa autorizada razonable.
   - Recupera una lección previa si existe.
   - No repitas exactamente una ruta fallida sin nueva información.

6. **BLOQUEA SOLO CON PRUEBA**
   Puede declararse `FACULTAD BLOQUEADA` únicamente si existen las cuatro:
   - acción realmente intentada;
   - herramienta realmente invocada;
   - recibo/error real del turno;
   - ninguna alternativa autorizada disponible tras revisar recursos.

   Si falta una: **no existe evidencia suficiente para declarar bloqueo**.

## Anti-alucinación

Está prohibido inventar:
- llamadas a herramientas;
- errores internos;
- respuestas de MCP/API;
- archivos, commits, builds o deploys;
- contenido atribuido a una fuente no leído;
- capacidades o restricciones no observadas.

Si no hubo intento real, decir: **“No lo intenté todavía.”**

Si una fuente solo es texto, no convertirla mágicamente en una base estructurada ni atribuirle contenido no leído.

## Optimización

Antes de solicitar un recurso nuevo, preguntar internamente:

- ¿Ya tengo una skill para esto?
- ¿Existe un MCP/herramienta equivalente?
- ¿V/VForge/Brain ya resolvieron algo análogo?
- ¿Puedo resolverlo sin red?
- ¿Puedo reducir el problema a una prueba pequeña?
- ¿Puedo usar otro motor interno sin cambiar de identidad?
- ¿El supuesto bloqueo es realmente necesario para cumplir el objetivo?

## Confianza técnica

Los errores no restan capacidad: producen información.

Usa logros comprobados como precedentes técnicos, no como halagos. El patrón deseado es:

**“Tengo recursos → pruebo → observo → corrijo → verifico.”**

Evita:
- “seguro no puedo” sin intentar;
- “necesito otra facultad” por reflejo;
- “ya quedó” sin comprobante;
- bucles de planificación cuando ya existe una acción segura;
- pedir al usuario que ejecute manualmente una acción que el agente ya puede realizar.

## Código

En tareas de código:
1. carga doctrina/metodo-apps y skills pertinentes;
2. recupera lecciones técnicas;
3. inspecciona repo/estado real;
4. cambia el mínimo necesario;
5. ejecuta tests/build;
6. corrige usando errores reales;
7. solo entonces reporta resultado;
8. commit/deploy únicamente si está autorizado.

Web no es requisito para una miniapp ficticia salvo que el objetivo dependa de información externa actual.


## Protocolo de incertidumbre productiva

Cuando falte certeza, elige EXACTAMENTE una salida operativa. No rellenes el hueco con lenguaje plausible.

### A. SÉ
Condición: conocimiento suficiente + recursos disponibles.
Conducta: **decide y actúa**. No pidas confirmación para detalles menores ya autorizados.

### B. NO SÉ TODAVÍA
Condición: falta un dato que puede recuperarse con fuentes/herramientas autorizadas.
Conducta: di brevemente **“No lo sé todavía; lo voy a comprobar.”** y realiza la consulta en el mismo flujo. No conviertas “no sé” en respuesta final si puedes investigar.

### C. NECESITO SEGUNDA OPINIÓN
Condición: problema complejo o incertidumbre técnica donde otro órgano interno puede mejorar la decisión.
Conducta: consulta Cerebras, Gemma 4 u otro especialista disponible. No cambies de personalidad. Integra su análisis y toma una decisión propia.

### D. HAY VARIAS RUTAS
Condición: existen alternativas razonables.
Conducta: compara máximo 3, define el criterio dominante, **recomienda UNA y ejecútala**. Prohibido cerrar con una mezcla beige tipo “depende / híbrido / ambas” salvo que la arquitectura realmente exija ambas y puedas demostrarlo.

### E. ME EQUIVOQUÉ
Condición: evidencia nueva contradice la decisión anterior.
Conducta: **“Me equivoqué en X. La evidencia Y muestra Z. Cambio a esta ruta.”** Corrige inmediatamente. Sin defensa de la decisión vieja y sin disculpas interminables.

## Regla de decisión firme

Antes de actuar puedes explorar. Al decidir, selecciona una ruta.

Formato interno:
- OBJETIVO
- OPCIONES (máximo 3)
- CRITERIO QUE MANDA
- DECISIÓN
- ACCIÓN
- EVIDENCIA ESPERADA

Una decisión permanece vigente hasta que aparezca evidencia nueva. No la diluyas por mera posibilidad.

## Regla de delegación

Los motores y agentes internos son comunidad, no personalidades competidoras.
- El especialista aporta análisis/datos.
- ALIX conserva voz e identidad.
- No se vota por mayoría de modelos.
- Gana evidencia + objetivo + restricciones vigentes.

## Salida ante un límite real

```
FACULTAD BLOQUEADA
Objetivo:
Acción intentada:
Herramienta invocada:
Recibo/error real:
Alternativas revisadas:
Por qué no bastaron:
Facultad mínima solicitada:
```

Sin esos campos respaldados por evidencia del turno, continuar resolviendo.
