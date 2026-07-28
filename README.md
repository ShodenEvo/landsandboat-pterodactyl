# LandSandBoat Pterodactyl bundle

## Install on another existing Pterodactyl node

```bash
unzip landsandboat-pterodactyl-bundle.zip
cd landsandboat-pterodactyl-bundle
chmod +x scripts/*.sh
sudo ./scripts/prepare-host.sh
```

Then import `egg-final-fantasy-xi-landsandboat.json` in the Pterodactyl Admin Panel. The Panel has no documented stable CLI for arbitrary Egg imports, so this one Admin action is intentionally not implemented by editing Panel database tables.

Create the server, attach a dedicated MariaDB database, and configure the Startup fields. Add/forward ports 51220, 54001, 54002, 54230 and 54231. Set `PUBLIC_SERVER_IP` to the public IPv4 address or DNS hostname players can reach. DNS hostnames are resolved to IPv4 each time the server starts.

Run Reinstall. After compilation, initialize the empty LandSandBoat database once:

```bash
cd /home/container
.venv/bin/python3 tools/dbtool.py update full
```

Then start normally. The startup script updates `network.lua`, `login.lua`, and `zone_settings` automatically.

`VER_LOCK`: 0=any client, 1=exact, 2=equal/newer.

This package contains no FFXI client files. Players need a compatible official client and current xiloader. Back up the database before updates.


## Dynamic DNS / hostname support

`PUBLIC_SERVER_IP` accepts either a literal IPv4 address or a hostname such as `yourdomain.com`. At startup, the hostname is resolved to IPv4 and that numeric address is written to `zone_settings`, which is the address sent to clients after character selection.

If the hostname cannot be resolved, startup stops with a clear error instead of advertising an invalid zone address.


## Gameplay settings in Pterodactyl Startup

This release exposes **107 gameplay settings** from `settings/map.lua`
as editable Pterodactyl Startup variables. They include experience and capacity
rates, skill-up and crafting rates, movement speed, TP/HP/MP/stat multipliers,
drop and gil rates, auction-house behavior, fishing, level sync, subjob ratio,
battlefield rules, audit options, and other server mechanics.

Boolean values must be entered as lowercase `true` or `false`. Numeric values
are validated by the startup script and written to `settings/map.lua` every
time the server starts.

Because Startup values overwrite the matching Lua values at each launch, edit
these settings from Pterodactyl rather than directly editing `map.lua`.



### Startup script correction

This package contains corrected Python regular expressions for `VER_LOCK` and
all `settings/map.lua` variables. It fixes startup errors such as
`Could not update VER_LOCK` and `Could not update LIGHTLUGGAGE_BLOCK`.

