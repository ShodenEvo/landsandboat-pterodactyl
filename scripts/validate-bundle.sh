#!/usr/bin/env bash
set -Eeuo pipefail
R="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
python3 -m json.tool "$R/egg-final-fantasy-xi-landsandboat.json" >/dev/null
for f in "$R"/scripts/*.sh; do bash -n "$f"; done
echo "Validation passed"
