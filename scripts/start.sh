#!/usr/bin/env bash
set -Eeuo pipefail
cd /home/container
for n in DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD PUBLIC_SERVER_IP VER_LOCK MAP_PORT SEARCH_PORT LOGIN_DATA_PORT LOGIN_VIEW_PORT LOGIN_AUTH_PORT LOGIN_CONF_PORT; do
  [[ -n "${!n:-}" ]] || { echo "Missing $n" >&2; exit 1; }
done
python3 - <<'PY'
from pathlib import Path
import os,re
def sub(t,p,r,n):
    t,c=re.subn(p,r,t,count=1,flags=re.M)
    if c!=1: raise RuntimeError(f"Could not update {n}")
    return t
v=int(os.environ["VER_LOCK"])
if v not in (0,1,2): raise RuntimeError("VER_LOCK must be 0, 1, or 2")
p=Path("settings/network.lua"); t=p.read_text()
sv={"SQL_HOST":os.environ["DB_HOST"],"SQL_LOGIN":os.environ["DB_USER"],"SQL_PASSWORD":os.environ["DB_PASSWORD"],"SQL_DATABASE":os.environ["DB_NAME"]}
iv={"SQL_PORT":int(os.environ["DB_PORT"]),"LOGIN_DATA_PORT":int(os.environ["LOGIN_DATA_PORT"]),"LOGIN_VIEW_PORT":int(os.environ["LOGIN_VIEW_PORT"]),"LOGIN_AUTH_PORT":int(os.environ["LOGIN_AUTH_PORT"]),"LOGIN_CONF_PORT":int(os.environ["LOGIN_CONF_PORT"]),"MAP_PORT":int(os.environ["MAP_PORT"]),"SEARCH_PORT":int(os.environ["SEARCH_PORT"])}
for k,x in sv.items():
    x=x.replace("\\","\\\\").replace("'","\\'")
    t=sub(t,rf"^\s*{k}\s*=\s*'.*?'\s*,",f"    {k:<16} = '{x}',",k)
for k,x in iv.items():
    if not 1<=x<=65535: raise RuntimeError(f"Bad port: {k}")
    t=sub(t,rf"^\s*{k}\s*=\s*\d+\s*,",f"    {k:<16} = {x},",k)
p.write_text(t)
p=Path("settings/login.lua"); t=p.read_text()
p.write_text(sub(t,r"^\s*VER_LOCK\s*=\s*\d+\s*,",f"    VER_LOCK = {v},","VER_LOCK"))
PY
.venv/bin/python3 - <<'PYDB'
import os,socket,mariadb
public_address=os.environ["PUBLIC_SERVER_IP"].strip()
try:
    resolved_ip=socket.gethostbyname(public_address)
except socket.gaierror as exc:
    raise RuntimeError(f"Could not resolve PUBLIC_SERVER_IP {public_address}: {exc}") from exc
print(f"Resolved {public_address} to {resolved_ip}")
c=mariadb.connect(host=os.environ["DB_HOST"],port=int(os.environ["DB_PORT"]),user=os.environ["DB_USER"],password=os.environ["DB_PASSWORD"],database=os.environ["DB_NAME"])
q=c.cursor(); q.execute("UPDATE zone_settings SET zoneip=?,zoneport=? WHERE zoneport<>0",(resolved_ip,int(os.environ["MAP_PORT"]))); c.commit(); q.close(); c.close()
PYDB
cleanup(){ code=$?; for p in "${CONNECT_PID:-}" "${SEARCH_PID:-}" "${WORLD_PID:-}" "${MAP_PID:-}"; do [[ -n "$p" ]] && kill "$p" 2>/dev/null || true; done; wait 2>/dev/null || true; exit "$code"; }
trap cleanup EXIT INT TERM
./xi_connect & CONNECT_PID=$!
./xi_search & SEARCH_PID=$!
./xi_world & WORLD_PID=$!
sleep 3
./xi_map & MAP_PID=$!
wait -n "$CONNECT_PID" "$SEARCH_PID" "$WORLD_PID" "$MAP_PID"
