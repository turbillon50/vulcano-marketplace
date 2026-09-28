#!/usr/bin/env bash
set -euo pipefail
export PATH=/opt/node-v22.14.0-linux-x64/bin:$PATH
DRIVE=""; SLUG=""; IDS=""; COVER=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --drive) DRIVE="$2"; shift 2;;
    --slug) SLUG="$2"; shift 2;;
    --property-ids) IDS="$2"; shift 2;;
    --cover) COVER="$2"; shift 2;;
    *) echo "unknown_arg:$1" >&2; exit 2;;
  esac
done
[[ -n "$DRIVE" && -n "$SLUG" && -n "$IDS" ]] || { echo "usage: --drive URL --slug slug --property-ids 1,2 [--cover filename]" >&2; exit 2; }
REPO=/root/repos/vliving-2026
[[ -d "$REPO" ]] || { echo "missing_repo" >&2; exit 3; }
WORK=$(mktemp -d /root/tmp/vliving-media-XXXXXX)
ENVFILE="$WORK/.env.production"
cleanup(){ rm -rf "$WORK"; }
trap cleanup EXIT
mkdir -p "$WORK/input"
# Google Drive folder must be public/readable. Do not print file contents or secrets.
gdown --folder "$DRIVE" -O "$WORK/input" >/dev/null
cd "$REPO"
vercel env pull "$ENVFILE" --environment=production --yes >/dev/null
chmod 600 "$ENVFILE"
CMD=(node /root/skills-vault/vliving-media-ingest/scripts/ingest.mjs --input "$WORK/input" --slug "$SLUG" --property-ids "$IDS" --env "$ENVFILE")
[[ -n "$COVER" ]] && CMD+=(--cover "$COVER")
"${CMD[@]}"
