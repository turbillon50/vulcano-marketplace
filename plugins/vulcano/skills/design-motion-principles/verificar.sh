#!/bin/bash
d="$(dirname "$0")"; for x in SKILL.md workflows/create.md workflows/audit.md; do [ -s "$d/$x" ] || { echo "falta $x"; exit 1; }; done; echo "OK: motion principles con modos create/audit"
