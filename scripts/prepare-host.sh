#!/usr/bin/env bash
set -Eeuo pipefail
R="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
docker build -t "${IMAGE_NAME:-landsandboat-pterodactyl:latest}" "$R"
echo "Image built. Import $R/egg-final-fantasy-xi-landsandboat.json in Pterodactyl Admin, create the server, attach a MariaDB database, add ports 51220/54001/54002/54230/54231, then Reinstall."
