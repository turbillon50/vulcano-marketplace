---
name: docusign-firma
description: Enviar contratos VMomentum a firma electronica via DocuSign API (JWT). ACTIVAR cuando Luis diga "manda el contrato", "a firma", "DocuSign", "que firme el cliente", o al cerrar fase de contratacion de entrega-cliente. Flujo probado end-to-end el 6 jun 2026 (sobre e28c23f2 completed).
---
# DOCUSIGN FIRMA — flujo probado

## Credenciales (sandbox demo, cuenta colectivo mass 48484008)
En Hetzner: `/root/.docusign/env` + RSA privada `/root/.docusign/private.key` (chmod 600). Integration Key 1a621517-cd5e-4a40-9aff-4d3a6c875ce4; User 5bd7e84b-f98d-42ec-b88d-d82b3b8b9fa3; Account 2b76fbc4-6b5f-44ca-92b0-f83a882cda11; base https://demo.docusign.net; OAuth account-d.docusign.com. Produccion (go-live pendiente): User 843f9659..., Account 19ed64aa..., base na4.docusign.net, OAuth account.docusign.com.

## Flujo (scripts ya en /root/.docusign/)
1. **Token JWT**: payload {iss=IntegrationKey, sub=UserID, aud=host OAuth, scope "signature impersonation"} firmado RS256 con la RSA → POST /oauth/token (grant jwt-bearer). Si responde `consent_required` → Luis abre https://account-d.docusign.com/oauth/auth?response_type=code&scope=signature%20impersonation&client_id=IK&redirect_uri=https://vforge.site/api/docusign/callback y da Allow (una vez).
2. **Contrato PDF**: plantilla membretada en skills-vault `contrato-premium` / outputs contrato-vmomentum.html → weasyprint. SIEMPRE gate visual (pdftoppm + mirar).
3. **Enviar sobre**: POST /restapi/v2.1/accounts/{accountId}/envelopes con documentBase64, signer {email, name}, tabs con `anchorString: "EL CLIENTE"` (signHere offset Y -40, dateSigned offset Y +30), status "sent". Script: /root/.docusign/send_test.py.
4. **Verificar**: GET /envelopes/{id} → status completed. Script: /root/.docusign/chk.py.
5. **Al completarse** → disparar onboarding de [entrega-cliente]: bienvenida Resend + Centro de Proyecto + solicitud pago 1 ($4,000 Plan 4 You).

## Pendientes
Webhook DocuSign Connect → endpoint vforge.site para automatizar el paso 5; go-live de la Integration Key a produccion cuando el flujo este pulido. Redirect/privacidad/terminos en vforge.site (ejecutor encadenado). Relacionado: [contrato-premium], [entrega-cliente].
