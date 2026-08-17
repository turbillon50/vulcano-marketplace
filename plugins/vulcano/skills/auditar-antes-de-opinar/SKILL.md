---
name: auditar-antes-de-opinar
description: Medir el estado real del sistema con comandos en vez de suponer. ACTIVAR cuando alguien diga que todo esta mal o que nada funciona.
---

No discutir. Medir.

df -h /
docker ps --format "{{.Names}} | {{.Status}}"
for r in / /propiedades /hilo; do curl -s -o /dev/null -w "$r %{http_code}\n" https://vliving.site$r; done
git log -10 --format="%h | %cr | %an | %s"

Reportar con evidencia: que esta vivo, que esta roto, cual es la causa raiz.
La diferencia entre 'creo que' y 'aqui esta la salida del comando' es toda la diferencia.
