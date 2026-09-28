---
name: auto-verify
description: Verificacion automatica via Twilio SMS y Resend email.
---
# Auto Verify
Usa Twilio para recibir SMS de verificacion automaticamente.
## Credenciales
Guardadas en Neon Brain tabla credentials_registry (proyecto: global, servicio: twilio).
Consultar con: SELECT env_var_name FROM credentials_registry WHERE service = twilio
## Flujo
1. Dar el numero Twilio al servicio que pide verificacion
2. Esperar 10s
3. Leer SMS via Twilio API Messages endpoint
4. Extraer codigo numerico de 4-8 digitos
5. Ingresar codigo en el servicio
