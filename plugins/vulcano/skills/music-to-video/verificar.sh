#!/usr/bin/env bash
# Verifica music-to-video HOY: analyze-beatgrid.py (librosa+soundfile+ffmpeg)
# convierte una pista generada en audiomap.json con bpm y beats reales —
# el motor de toda la skill — y validate-plan.mjs se niega sin STORYBOARD.
. /root/skills-vault/_lib/verif.sh
echo "verificando music-to-video"
export NVM_DIR=/root/.nvm; . $NVM_DIR/nvm.sh >/dev/null 2>&1; nvm use 20 >/dev/null 2>&1
D=$(cd "$(dirname "$0")" && pwd)
_t=$(mktemp -d)

paso "analyze-beatgrid.py produce audiomap.json de una pista real"
# Click track sintetico: clic de 1000 Hz con decaimiento cada 0.5 s (120 bpm).
# Un seno con tremolo no basta — el beat tracker de librosa necesita onsets
# percusivos, y con un tono puro regresa 0 beats (medido).
ffmpeg -hide_banner -loglevel error \
  -f lavfi -i "aevalsrc=if(lt(mod(t\,0.5)\,0.03)\,sin(2*PI*1000*t)*exp(-60*mod(t\,0.5))\,0):d=6:s=44100" \
  -y "$_t/pista.wav" >/dev/null 2>&1
if python3 "$D/scripts/analyze-beatgrid.py" "$_t/pista.wav" -o "$_t/audiomap.json" >/dev/null 2>&1 \
   && python3 -c "
import json
m=json.load(open('$_t/audiomap.json'))
bpm=float(m['tempo']['bpm'])
beats=m['grid']['beats_sec']
assert bpm>0, 'sin bpm'
assert len(beats)>=4, 'solo %s beats' % len(beats)
" 2>/dev/null; then
  BPM=$(python3 -c "import json;m=json.load(open('$_t/audiomap.json'));print(round(float(m['tempo']['bpm']),1))" 2>/dev/null)
  ok "audiomap.json con bpm=${BPM:-?} y grid de beats"
else
  falla "analyze-beatgrid.py no produjo audiomap usable (librosa/soundfile/ffmpeg)"
fi

paso "el parser de storyboard vendido compila"
if node --check "$D/scripts/lib/storyboard.mjs" 2>&1 && node --check "$D/scripts/validate-plan.mjs" 2>&1; then
  ok "storyboard.mjs + validate-plan.mjs"
else
  falla "el parser o el validador no compilan"
fi

debe_reprobar "validate-plan.mjs se niega sin STORYBOARD.md" \
  node "$D/scripts/validate-plan.mjs" --storyboard "$_t/no-existe.md" --audiomap "$_t/no-existe.json"

paso "stage-assets y assemble-index compilan"
if node --check "$D/scripts/stage-assets.mjs" 2>&1 && node --check "$D/scripts/assemble-index.mjs" 2>&1; then
  ok "sintaxis valida"
else
  falla "stage-assets/assemble-index no compilan"
fi
rm -rf "$_t"
cierra
