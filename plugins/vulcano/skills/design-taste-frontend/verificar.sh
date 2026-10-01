#!/bin/bash
f="$(dirname "$0")/SKILL.md"; grep -q '^name: design-taste-frontend' "$f" && [ $(wc -l < "$f") -gt 500 ] && echo "OK: taste skill completa" || { echo "SKILL.md incompleto"; exit 1; }
