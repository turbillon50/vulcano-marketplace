#!/usr/bin/env python3
"""calca.py — instrumento de La Calca (VForge). Solo dependencias: PIL + numpy.

  python3 calca.py medir referencia.png
      Paleta por roles (bg/surface/accent/texto) + contraste WCAG de la referencia.

  python3 calca.py comparar referencia.png captura.png --out /tmp/calca
      La hoja de calca: overlay 50%, mapa de diferencia en rojo, % de píxeles
      distintos y las 3 peores regiones (dónde corregir).

El % informa; el ojo (o visual-judge) decide. Compilar NO equivale a calcar.
"""
import argparse
import os
import sys

import numpy as np
from PIL import Image

GRID_X, GRID_Y = 6, 4          # regiones para localizar diferencias
PIXEL_UMBRAL = 24              # canal por encima de esto cuenta como "distinto"


def _cargar(ruta):
    img = Image.open(ruta).convert("RGB")
    return img


def _hex(rgb):
    return "#{:02x}{:02x}{:02x}".format(*[int(v) for v in rgb])


def _contraste(a, b):
    def lum(c):
        v = [x / 255.0 for x in c]
        v = [x / 12.92 if x <= 0.04045 else ((x + 0.055) / 1.055) ** 2.4 for x in v]
        return 0.2126 * v[0] + 0.7152 * v[1] + 0.0722 * v[2]
    la, lb = lum(a), lum(b)
    lo, hi = min(la, lb), max(la, lb)
    return (hi + 0.05) / (lo + 0.05)


def medir(ruta):
    img = _cargar(ruta)
    chica = img.copy()
    chica.thumbnail((400, 400))
    q = chica.quantize(colors=8, method=Image.Quantize.MEDIANCUT)
    pal = np.array(q.getpalette()[:24]).reshape(8, 3)
    conteos = np.bincount(np.array(q).ravel(), minlength=8)
    total = int(conteos.sum())
    ranks = np.argsort(conteos)[::-1]
    orden = [pal[i] for i in ranks]

    def saturacion(c):
        r, g, b = [x / 255.0 for x in c]
        mx, mn = max(r, g, b), min(r, g, b)
        return 0.0 if mx == 0 else (mx - mn) / mx

    print(f"== {ruta}  ({img.width}x{img.height})")
    print("\nPaleta dominante (fondo -> detalles):")
    for pos, i in enumerate(ranks):
        c = pal[i]
        print(f"  {pos+1}. {_hex(c)}  {100.0*conteos[i]/total:5.1f}%   rgb{tuple(int(x) for x in c)}")

    bg = orden[0]
    oscuro_bg = float(np.mean(bg)) < 128
    texto = max(orden[1:], key=lambda c: abs(float(np.mean(c)) - float(np.mean(bg))))
    acento = max(orden[1:], key=saturacion)
    print("\nRoles sugeridos (a validar contra la imagen por ojo):")
    print(f"  --color-bg:      {_hex(bg)}   ({'oscuro' if oscuro_bg else 'claro'})")
    if len(orden) > 2:
        print(f"  --color-surface: {_hex(orden[2])}")
    print(f"  --color-text:    {_hex(texto)}   contraste vs bg: {_contraste(texto, bg):.1f}:1 "
          f"({'OK AA' if _contraste(texto, bg) >= 4.5 else 'FALLA AA texto'})")
    print(f"  --color-accent:  {_hex(acento)}   contraste vs bg: {_contraste(acento, bg):.1f}:1")
    print(f"\nTema: {'dark' if oscuro_bg else 'light'}. Copia estos valores a tokens.css "
          "SOLO si la imagen es la referencia aprobada.")


def comparar(ref_ruta, cap_ruta, out):
    ref = _cargar(ref_ruta)
    cap = _cargar(cap_ruta)
    if ref.size != cap.size:
        print(f"! tamaños distintos: ref {ref.size} vs captura {cap.size} -> "
              f"ajusto la captura a la referencia (calca honesta = mismo viewport)")
        cap = cap.resize(ref.size, Image.LANCZOS)
    a = np.asarray(ref, dtype=np.int16)
    b = np.asarray(cap, dtype=np.int16)
    diff = np.abs(a - b).max(axis=2)            # 0..255 por píxel

    os.makedirs(out, exist_ok=True)
    # 1) overlay 50% — la hoja encima del dibujo
    Image.blend(ref, cap, 0.5).save(os.path.join(out, "overlay50.png"))
    # 2) mapa de calor: blanco = igual, rojo = distinto
    heat = np.clip(diff * 3, 0, 255).astype(np.uint8)
    mapa = np.stack([np.full_like(heat, 255),
                     255 - heat,
                     255 - heat], axis=2)
    Image.fromarray(mapa).save(os.path.join(out, "difference.png"))

    total = diff.size
    distintos = int((diff > PIXEL_UMBRAL).sum())
    pct = 100.0 * distintos / total
    print(f"== referencia : {ref_ruta}")
    print(f"== captura    : {cap_ruta} ({cap.size[0]}x{cap.size[1]})")
    print(f"== píxeles distintos (>{PIXEL_UMBRAL}/255): {distintos:,} = {pct:.1f}%")
    print(f"== diff media : {diff.mean():.1f}/255")

    # peores regiones
    h, w = diff.shape
    cw, ch = w // GRID_X, h // GRID_Y
    celdas = []
    for gy in range(GRID_Y):
        for gx in range(GRID_X):
            c = diff[gy*ch:(gy+1)*ch, gx*cw:(gx+1)*cw]
            celdas.append((100.0*(c > PIXEL_UMBRAL).mean(), gx, gy))
    celdas.sort(reverse=True)
    nombres_x = ["izquierda", "centro-izq", "centro", "centro", "centro-der", "derecha"]
    nombres_y = ["arriba", "arriba-medio", "abajo-medio", "abajo"]
    print("== peores regiones (corrige aquí primero):")
    for p, gx, gy in celdas[:3]:
        print(f"   {p:5.1f}% distinto  -> {nombres_y[gy]}-{nombres_x[gx]} "
              f"(x{gx*cw}..{(gx+1)*cw}, y{gy*ch}..{(gy+1)*ch})")
    print(f"\nSalidas: {out}/overlay50.png (calca), {out}/difference.png (dónde)")
    if pct < 8:
        print("Veredicto del número: CALCA FINA — confirmar con ojo humano/judge.")
    elif pct < 20:
        print("Veredicto del número: EN PROGRESO — corregir regiones y repetir.")
    else:
        print("Veredicto del número: NO PARECE — sigue calcando, no presentes.")


def main():
    ap = argparse.ArgumentParser(description="Instrumento de La Calca")
    sub = ap.add_subparsers(dest="cmd", required=True)
    m = sub.add_parser("medir", help="paleta y roles de una referencia")
    m.add_argument("imagen")
    c = sub.add_parser("comparar", help="captura vs referencia")
    c.add_argument("referencia")
    c.add_argument("captura")
    c.add_argument("--out", default="/tmp/calca")
    args = ap.parse_args()
    if args.cmd == "medir":
        medir(args.imagen)
    else:
        comparar(args.referencia, args.captura, args.out)


if __name__ == "__main__":
    sys.exit(main())
