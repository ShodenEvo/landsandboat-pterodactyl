# LandSandBoat Pterodactyl bundle

## Install on another existing Pterodactyl node

```bash
unzip landsandboat-pterodactyl-bundle.zip
cd landsandboat-pterodactyl-bundle
chmod +x scripts/*.sh
sudo ./scripts/prepare-host.sh
```

Then import `egg-final-fantasy-xi-landsandboat.json` in the Pterodactyl Admin Panel. The Panel has no documented stable CLI for arbitrary Egg imports, so this one Admin action is intentionally not implemented by editing Panel database tables.

Create the server, attach a dedicated MariaDB database, and configure the Startup fields. Add/forward ports 51220, 54001, 54002, 54230 and 54231. Set `PUBLIC_SERVER_IP` to the address players can reach.

Run Reinstall. After compilation, initialize the empty LandSandBoat database once:

```bash
cd /home/container
.venv/bin/python3 tools/dbtool.py update full
```

Then start normally. The startup script updates `network.lua`, `login.lua`, and `zone_settings` automatically.

`VER_LOCK`: 0=any client, 1=exact, 2=equal/newer.

This package contains no FFXI client files. Players need a compatible official client and current xiloader. Back up the database before updates.
