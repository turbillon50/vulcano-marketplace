---
name: rescate-disco
description: Diagnosticar y rescatar un servidor con el disco lleno o servicios que se caen solos. ACTIVAR cuando el servidor vaya lento, un servicio falle sin explicacion o algo se reinicie solo.
---

df -h /
du -xh --max-depth=1 / | sort -rh | head -8
ls -laS /var/log/ | head -6

Causa real encontrada: un servicio rebotando por puerto ocupado, 485 mil reinicios, 9 GB de log.
journalctl -S "-2 hours" | awk '{print $5}' | sed 's/\[.*//' | sort | uniq -c | sort -rn | head

Rescate: truncar con : > archivo (nunca borrar, el proceso lo tiene abierto).
journalctl --vacuum-size=80M. Detener el servicio en bucle.
Candados: logrotate cada hora tope 200M, StartLimitBurst=3, limite en daemon.json.
