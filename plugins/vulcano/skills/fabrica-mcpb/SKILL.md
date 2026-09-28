---
name: fabrica-mcpb
description: Fabricar conectores .mcpb instalables con doble clic (para V, Mercado Pago y CUALQUIER servidor MCP remoto de terceros). Producto vendible de VMomentum. ACTIVAR cuando Luis diga "hazme el mcpb de X", "conector instalable", "empaqueta el MCP", o cuando un cliente necesite conectar su agente a un servicio sin tocar terminal.
---
# FABRICA DE .MCPB — conectores con doble clic

Un .mcpb es un paquete (manifest.json + entry + icono, comprimido con la CLI oficial) que Claude Desktop instala con doble clic y muestra campos de configuracion amigables. VMomentum los fabrica para sus productos Y para terceros (servicio cobrable: "tu servicio instalable en Claude").

## RECETA (validada 8 jun 2026 con V.mcpb y MercadoPago.mcpb)
1. Carpeta con: manifest.json, server/index.js (stub comentado), icon.png (256x256, PIL).
2. manifest.json claves: manifest_version 0.2; name/display_name/version/description/long_description (con instrucciones de donde sacar el token); author; icon; server{type:node, entry_point, mcp_config}; user_config con campos sensitive para tokens.
3. mcp_config para servidor REMOTO: command npx, args ["-y","mcp-remote@latest","<URL>","--transport","http-only","--header","Authorization:${AUTH_HEADER}"], env {AUTH_HEADER: "Bearer ${user_config.token}"}.
4. **TRAMPA WINDOWS (critica)**: NUNCA poner el header con espacio en args ("Authorization: Bearer X" se parte al spawnear y da "Server disconnected"). El valor con espacios SIEMPRE va en env; en args solo "Authorization:${VAR}" sin espacios.
5. Empaquetar: npx -y @anthropic-ai/mcpb pack <dir> <Salida>.mcpb
6. PROBAR antes de entregar: npx -y mcp-remote <URL> --header "Authorization: Bearer <token>" debe decir "Proxy established successfully".
7. Entregar el .mcpb + instrucciones: Ajustes → Extensiones → Instalar extension → archivo → pegar token → reiniciar Claude.

## COMO PRODUCTO PARA TERCEROS
Oferta: "Tu API/servicio instalable en Claude en 24h" — fabricamos su servidor MCP (si no lo tiene) + su .mcpb con marca propia (icono, nombre, campos). Precio sugerido: setup unico + opcional hosting del MCP en nuestra infra. Pipeline: API del cliente → wrapper MCP (vforge /api/mcp como referencia) → .mcpb → distribucion (su web o el MCP Registry oficial).

## Referencias internas
V.mcpb (vfmcp tokens por usuario), MercadoPago.mcpb (Access Token APP_USR-), leccion-mcpb-windows-header en brain. Relacionado: [v-mcp-server], [sumsub-kyc], [secret-injector].