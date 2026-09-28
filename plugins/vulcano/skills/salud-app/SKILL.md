---
name: salud-app
description: Chequeo rapido de salud de una app en produccion, con evidencia y sin adivinar. Revisa: deploy READY en Vercel, /api/health, dominio/DNS resolviendo, login real funcionando, datos reales vs mock, y la PWA. ACTIVAR cuando Luis pregunte como esta X app, si jala, esta viva, esta bien, revisa el estado, esta caida.
---
# Salud de app
Pasos: 1) Vercel: ultimo deployment production = READY (no ERROR/BLOCKED). 2) GET /api/health -> ok. 3) dig dominio -> apunta a Vercel (76.76.21.21). 4) abrir en navegador: carga, login no rebota, se ve la app correcta (no demo/otra). 5) datos reales (no mock). 6) PWA: manifest+sw+iconos 200. Reporta semaforo verde/amarillo/rojo por punto, con la evidencia textual. Usa ver-logs si algo falla.
