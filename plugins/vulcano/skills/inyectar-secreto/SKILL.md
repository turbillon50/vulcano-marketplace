---
name: inyectar-secreto
description: Validar e inyectar credenciales en Vercel y en el servidor. ACTIVAR cuando llegue una API key, token o credencial nueva.
---

1. Detectar el servicio por prefijo: sk_, pk_, re_, vcp_, ghp_, postgresql://
2. VALIDAR contra la API real antes de guardar. Una llave muerta cuesta horas.
3. Inyectar en production, preview y development de Vercel.
4. Escribir tambien en el .env.local del servidor.
5. Nunca imprimir el valor completo: enmascarar a 6 caracteres.
