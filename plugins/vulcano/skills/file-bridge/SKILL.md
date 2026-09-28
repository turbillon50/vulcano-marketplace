---
name: file-bridge
description: Transferir archivos entre Hetzner y Claude Chat sin corrupcion. ACTIVAR cuando se necesite mover imagenes, screenshots, archivos entre el servidor y este chat.
---
# File Bridge — Archivos sin corrupcion

## Endpoint de archivos (agregar al relay)
Agregar a brain-relay.py:

@app.route('/brain/file/<path:filepath>')
def serve_file(filepath):
    from flask import send_file
    return send_file(f'/home/{filepath}')

Asi cualquier archivo en /home/ es accesible via:
GET http://178.105.135.26/brain/file/{nombre}

## Transferir imagen Hetzner -> Chat
1. Guardar en Hetzner: page.screenshot(path='/home/screenshots/nombre.jpg')
2. Descargar: wget http://178.105.135.26/brain/file/screenshots/nombre.jpg
3. O via base64 con JPEG quality=30 para menor peso

## Transferir archivo Chat -> Hetzner
1. Si es texto: base64 encode -> POST /brain/exec echo {b64} | base64 -d > /home/{path}
2. Si es binario: guardar en /mnt/user-data/uploads/ y luego POST /brain/exec con curl para descargar

## Fix de base64
SIEMPRE agregar padding antes de decode:
padding = 4 - len(b64) % 4
if padding != 4: b64 += '=' * padding

## Regla para scripts complejos
SIEMPRE usar base64 para mandar scripts al relay:
1. Escribir script en Python local
2. base64.b64encode(script.encode()).decode()
3. POST /brain/exec: echo {b64} | base64 -d > /tmp/script.py && python3 /tmp/script.py

Esto evita el infierno de JSON escaping anidado.
