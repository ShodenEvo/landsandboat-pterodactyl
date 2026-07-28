#!/usr/bin/env bash
set -Eeuo pipefail
cd /home/container
for n in DB_HOST DB_PORT DB_NAME DB_USER DB_PASSWORD PUBLIC_SERVER_IP VER_LOCK MAP_PORT SEARCH_PORT LOGIN_DATA_PORT LOGIN_VIEW_PORT LOGIN_AUTH_PORT LOGIN_CONF_PORT LIGHTLUGGAGE_BLOCK LEAK_EXT_DATA_ON_ITEM_MOVE ENABLE_ITEM_RECYCLE_BIN SELF_UNSTUCK_ENABLED SELF_UNSTUCK_COOLDOWN AH_BASE_FEE_SINGLE AH_BASE_FEE_STACKS AH_TAX_RATE_SINGLE AH_TAX_RATE_STACKS AH_MAX_FEE AH_LIST_LIMIT ENMITY_CAP EXP_RATE EXP_LOSS_RATE EXP_PARTY_GAP_PENALTIES EXP_PARTY_GAP_NO_EXP CAPACITY_RATE FAME_MULTIPLIER EXP_RETAIN EXP_LOSS_LEVEL USE_PRE_ABYSSEA_EXP_LOSS_TIERS MINIMUM_LEVEL_CONQUEST_INFUENCE_LOSS LEVEL_SYNC_ENABLE DISABLE_GEAR_SCALING DISABLE_TREASURE_HUNTER_PROCS ENABLE_AUTO_ATTACK_LUA WS_POINTS_BASE WS_POINTS_SKILLCHAIN ALL_JOBS_WIDESCAN BASE_SPEED SPEED_LIMIT MOUNT_SPEED ANIMATION_SPEED_DIVISOR MOB_RUN_SPEED_MULTIPLIER SKILLUP_CHANCE_MULTIPLIER CRAFT_CHANCE_MULTIPLIER SKILLUP_AMOUNT_MULTIPLIER CRAFT_AMOUNT_MULTIPLIER GARDEN_DAY_MATTERS GARDEN_MOONPHASE_MATTERS GARDEN_POT_MATTERS GARDEN_MH_AURA_MATTERS CRAFT_MODERN_SYSTEM CRAFT_COMMON_CAP CRAFT_SPECIALIZATION_POINTS CRAFT_HQ_CHANCE_MULTIPLIER FISHING_ENABLE FISHING_MIN_LEVEL FISHING_SKILL_MULTIPLIER SKILLUP_BLOODPACT MOB_TP_MULTIPLIER PET_TP_MULTIPLIER PLAYER_TP_MULTIPLIER TRUST_TP_MULTIPLIER FELLOW_TP_MULTIPLIER NM_HP_MULTIPLIER MOB_HP_MULTIPLIER ALTER_EGO_HP_MULTIPLIER NM_MP_MULTIPLIER MOB_MP_MULTIPLIER ALTER_EGO_MP_MULTIPLIER SJ_MP_DIVISOR SUBJOB_RATIO INCLUDE_MOB_SJ NM_STAT_MULTIPLIER MOB_STAT_MULTIPLIER ALTER_EGO_STAT_MULTIPLIER ALTER_EGO_SKILL_MULTIPLIER ABILITY_RECAST_MULTIPLIER SPELL_RECAST_REDUCTION_CAP BLOOD_PACT_SHARED_TIMER DROP_RATE_MULTIPLIER MOB_GIL_MULTIPLIER ALL_MOBS_GIL_BONUS MAX_GIL_BONUS MOB_NO_DESPAWN MOB_ADDITIONAL_TIME_TO_DEAGGRO DEFENSIVE_OLD_SKILLUP_STYLE BATTLE_CAP_TWEAK LV_CAP_MISSION_BCNM BCNM_ENABLE_EXPERIMENTAL MAX_MERIT_POINTS YELL_COOLDOWN BLOCK_TELL_TO_HIDDEN_GM PREVENT_UNENGAGED_WS HIDE_READIES_TARGET AUDIT_GM_CMD AUDIT_CHAT AUDIT_SAY AUDIT_SHOUT AUDIT_TELL AUDIT_YELL AUDIT_LINKSHELL AUDIT_UNITY AUDIT_PARTY AUDIT_BALLISTA AUDIT_ASSISTE AUDIT_ASSISTJ AUDIT_PLAYER_TRADES AUDIT_PLAYER_BAZAAR AUDIT_PLAYER_DBOX AUDIT_PLAYER_VENDOR DELIVERY_BOX_MAX_INFLIGHT HEALING_TICK_DELAY KEEP_JUGPET_THROUGH_ZONING DESPAWN_JUGPETS_BELOW_MINIMUM_LEVEL REPORT_LUA_ERRORS_TO_PLAYER_LEVEL; do
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
p.write_text(sub(t,r"^\\s*VER_LOCK\\s*=\\s*\\d+\\s*,",f"    VER_LOCK = {v},","VER_LOCK"))

# Gameplay mechanics exposed through the Pterodactyl Startup menu.
map_types = {"LIGHTLUGGAGE_BLOCK":"int","LEAK_EXT_DATA_ON_ITEM_MOVE":"bool","ENABLE_ITEM_RECYCLE_BIN":"bool","SELF_UNSTUCK_ENABLED":"bool","SELF_UNSTUCK_COOLDOWN":"int","AH_BASE_FEE_SINGLE":"int","AH_BASE_FEE_STACKS":"int","AH_TAX_RATE_SINGLE":"float","AH_TAX_RATE_STACKS":"float","AH_MAX_FEE":"int","AH_LIST_LIMIT":"int","ENMITY_CAP":"int","EXP_RATE":"float","EXP_LOSS_RATE":"float","EXP_PARTY_GAP_PENALTIES":"bool","EXP_PARTY_GAP_NO_EXP":"int","CAPACITY_RATE":"float","FAME_MULTIPLIER":"float","EXP_RETAIN":"int","EXP_LOSS_LEVEL":"int","USE_PRE_ABYSSEA_EXP_LOSS_TIERS":"bool","MINIMUM_LEVEL_CONQUEST_INFUENCE_LOSS":"int","LEVEL_SYNC_ENABLE":"bool","DISABLE_GEAR_SCALING":"bool","DISABLE_TREASURE_HUNTER_PROCS":"bool","ENABLE_AUTO_ATTACK_LUA":"bool","WS_POINTS_BASE":"int","WS_POINTS_SKILLCHAIN":"int","ALL_JOBS_WIDESCAN":"bool","BASE_SPEED":"int","SPEED_LIMIT":"int","MOUNT_SPEED":"int","ANIMATION_SPEED_DIVISOR":"float","MOB_RUN_SPEED_MULTIPLIER":"float","SKILLUP_CHANCE_MULTIPLIER":"float","CRAFT_CHANCE_MULTIPLIER":"float","SKILLUP_AMOUNT_MULTIPLIER":"int","CRAFT_AMOUNT_MULTIPLIER":"int","GARDEN_DAY_MATTERS":"bool","GARDEN_MOONPHASE_MATTERS":"bool","GARDEN_POT_MATTERS":"bool","GARDEN_MH_AURA_MATTERS":"bool","CRAFT_MODERN_SYSTEM":"bool","CRAFT_COMMON_CAP":"int","CRAFT_SPECIALIZATION_POINTS":"int","CRAFT_HQ_CHANCE_MULTIPLIER":"float","FISHING_ENABLE":"bool","FISHING_MIN_LEVEL":"int","FISHING_SKILL_MULTIPLIER":"float","SKILLUP_BLOODPACT":"bool","MOB_TP_MULTIPLIER":"float","PET_TP_MULTIPLIER":"float","PLAYER_TP_MULTIPLIER":"float","TRUST_TP_MULTIPLIER":"float","FELLOW_TP_MULTIPLIER":"float","NM_HP_MULTIPLIER":"float","MOB_HP_MULTIPLIER":"float","ALTER_EGO_HP_MULTIPLIER":"float","NM_MP_MULTIPLIER":"float","MOB_MP_MULTIPLIER":"float","ALTER_EGO_MP_MULTIPLIER":"float","SJ_MP_DIVISOR":"float","SUBJOB_RATIO":"int","INCLUDE_MOB_SJ":"bool","NM_STAT_MULTIPLIER":"float","MOB_STAT_MULTIPLIER":"float","ALTER_EGO_STAT_MULTIPLIER":"float","ALTER_EGO_SKILL_MULTIPLIER":"float","ABILITY_RECAST_MULTIPLIER":"float","SPELL_RECAST_REDUCTION_CAP":"int","BLOOD_PACT_SHARED_TIMER":"bool","DROP_RATE_MULTIPLIER":"float","MOB_GIL_MULTIPLIER":"float","ALL_MOBS_GIL_BONUS":"int","MAX_GIL_BONUS":"int","MOB_NO_DESPAWN":"bool","MOB_ADDITIONAL_TIME_TO_DEAGGRO":"int","DEFENSIVE_OLD_SKILLUP_STYLE":"bool","BATTLE_CAP_TWEAK":"int","LV_CAP_MISSION_BCNM":"bool","BCNM_ENABLE_EXPERIMENTAL":"bool","MAX_MERIT_POINTS":"int","YELL_COOLDOWN":"int","BLOCK_TELL_TO_HIDDEN_GM":"bool","PREVENT_UNENGAGED_WS":"bool","HIDE_READIES_TARGET":"bool","AUDIT_GM_CMD":"bool","AUDIT_CHAT":"bool","AUDIT_SAY":"bool","AUDIT_SHOUT":"bool","AUDIT_TELL":"bool","AUDIT_YELL":"bool","AUDIT_LINKSHELL":"bool","AUDIT_UNITY":"bool","AUDIT_PARTY":"bool","AUDIT_BALLISTA":"bool","AUDIT_ASSISTE":"bool","AUDIT_ASSISTJ":"bool","AUDIT_PLAYER_TRADES":"bool","AUDIT_PLAYER_BAZAAR":"bool","AUDIT_PLAYER_DBOX":"bool","AUDIT_PLAYER_VENDOR":"bool","DELIVERY_BOX_MAX_INFLIGHT":"int","HEALING_TICK_DELAY":"int","KEEP_JUGPET_THROUGH_ZONING":"bool","DESPAWN_JUGPETS_BELOW_MINIMUM_LEVEL":"bool","REPORT_LUA_ERRORS_TO_PLAYER_LEVEL":"int"}
p = Path("settings/map.lua")
t = p.read_text()
for key, value_type in map_types.items():
    raw = os.environ[key].strip()
    if value_type == "bool":
        lowered = raw.lower()
        if lowered not in ("true", "false"):
            raise RuntimeError(f"{key} must be true or false")
        rendered = lowered
        pattern = rf"^\\s*{key}\\s*=\\s*(?:true|false)\\s*,"
    elif value_type == "int":
        rendered = str(int(raw))
        pattern = rf"^\\s*{key}\\s*=\\s*-?\\d+\\s*,"
    else:
        rendered = str(float(raw))
        pattern = rf"^\\s*{key}\\s*=\\s*-?\\d+(?:\\.\\d+)?\\s*,"
    t = sub(t, pattern, f"    {key} = {rendered},", key)
p.write_text(t)
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
