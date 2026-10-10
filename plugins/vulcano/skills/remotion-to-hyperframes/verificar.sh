#!/usr/bin/env bash
# Verifica remotion-to-hyperframes HOY: corre el smoke propio del arnes —
# genera dos videos con ffmpeg, comprueba que render_diff (SSIM) aprueba
# copias identicas y reprueba patrones distintos, frame_strip produce la
# tira, y lint_source acepta el fixture limpio y rechaza el de blockers.
. /root/skills-vault/_lib/verif.sh
echo "verificando remotion-to-hyperframes"
D=$(cd "$(dirname "$0")" && pwd)

paso "herramientas del arnes (ffmpeg + python3)"
if command -v ffmpeg >/dev/null && command -v python3 >/dev/null; then
  ok "ffmpeg $(ffmpeg -version 2>/dev/null | head -1 | grep -oE 'version [0-9.]+' )"
else
  falla "faltan ffmpeg o python3"
fi

paso "smoke del arnes: SSIM identico/diferente, frame_strip, lint de fixtures"
OUT=$(timeout 55 bash "$D/scripts/tests/smoke.sh" 2>&1); RC=$?
if [ "$RC" -eq 0 ] && printf '%s' "$OUT" | grep -q 'smoke tests passed'; then
  SSIM=$(printf '%s' "$OUT" | sed -n 's/.*identical inputs → mean SSIM=\([0-9.]*\).*/\1/p' | head -1)
  BLK=$(printf '%s' "$OUT" | sed -n 's/.*blocker.tsx → \([0-9]*\) blockers.*/\1/p' | head -1)
  ok "SSIM copia=$SSIM, blocker.tsx=$BLK blockers detectados"
else
  falla "smoke.sh salio $RC: $(printf '%s' "$OUT" | grep -E 'FAIL|Error' | head -2 | tr '\n' ' ')"
fi

debe_reprobar "lint_source.py rechaza el fixture blocker a mano (no solo dentro del smoke)" \
  python3 "$D/scripts/lint_source.py" "$D/scripts/tests/fixtures/blocker.tsx" --json
cierra
