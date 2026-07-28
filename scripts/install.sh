#!/usr/bin/env bash
set -Eeuo pipefail
cd /mnt/server
REPO="${LSB_REPO_URL:-https://github.com/LandSandBoat/server.git}"
REF="${LSB_REPO_REF:-base}"
JOBS="${BUILD_JOBS:-2}"
git clone --recursive --branch "$REF" "$REPO" .
python3 -m venv .venv
.venv/bin/pip install --upgrade pip
.venv/bin/pip install -r tools/requirements.txt
python3 - <<'PY'
from pathlib import Path
p=Path("ext/CMakeLists.txt")
if p.exists():
 t=p.read_text().replace("set(CPPTRACE_GET_SYMBOLS_WITH_LIBDWARF ON)","set(CPPTRACE_GET_SYMBOLS_WITH_LIBDWARF OFF)").replace("set(CPPTRACE_GET_SYMBOLS_WITH_ADDR2LINE OFF)","set(CPPTRACE_GET_SYMBOLS_WITH_ADDR2LINE ON)")
 p.write_text(t)
PY
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DPython_EXECUTABLE=/mnt/server/.venv/bin/python3
cmake --build build --parallel "$JOBS"
for b in xi_connect xi_search xi_world xi_map; do
 f="$(find build -type f -name "$b" -perm -u+x | head -n1)"
 [[ -n "$f" ]] || { echo "$b missing" >&2; exit 1; }
 cp -f "$f" "/mnt/server/$b"; chmod +x "/mnt/server/$b"
done
mkdir -p settings pterodactyl log
for s in settings/default/*.lua; do d="settings/$(basename "$s")"; [[ -f "$d" ]] || cp "$s" "$d"; done
cp /opt/lsb-bundle/start.sh /mnt/server/pterodactyl/start.sh
chmod +x /mnt/server/pterodactyl/start.sh
echo "Build complete. Initialize the DB once with: .venv/bin/python3 tools/dbtool.py update full"
