LandSandBoat Pterodactyl Egg

A reusable Pterodactyl deployment bundle for hosting a LandSandBoat FINAL FANTASY XI private server.

This repository provides a custom Pterodactyl Egg, Docker runtime image, installation scripts, startup automation, database helpers, and documentation for deploying LandSandBoat on a Pterodactyl Wings node.

This project does not include FINAL FANTASY XI client files, copyrighted game data, Square Enix software, account credentials, or character databases.

Features

Custom Pterodactyl Egg for LandSandBoat

Builds LandSandBoat from the official source repository

Configurable branch, tag, or commit

Automatic Python virtual environment setup

Automatic compilation of xi_connect, xi_search, xi_world, and xi_map

Startup-menu configuration for database connection details

Configurable public server IP

Configurable client version lock

Configurable login, search, and map ports

Automatically updates settings/network.lua

Automatically updates settings/login.lua

Automatically updates zone_settings.zoneip and zoneport

Database backup helper

Bundle validation script

Repository contents

.
├── Dockerfile
├── README.md
├── SHA256SUMS
├── egg-final-fantasy-xi-landsandboat.json
└── scripts
    ├── backup-database.sh
    ├── install.sh
    ├── prepare-host.sh
    ├── start.sh
    └── validate-bundle.sh

Requirements

A working Pterodactyl Panel and Wings installation

Root or sudo access to the Wings node

Docker

A MariaDB database reachable from the game container

Sufficient storage, RAM, and CPU time to compile LandSandBoat

A legitimate FINAL FANTASY XI client installation for each player

A current compatible LandSandBoat xiloader

Quick installation

Clone the repository on the Pterodactyl Wings node:

git clone https://github.com/YOUR-GITHUB-USERNAME/landsandboat-pterodactyl.git
cd landsandboat-pterodactyl
chmod +x scripts/*.sh
sudo ./scripts/prepare-host.sh

This builds the local Docker image:

landsandboat-pterodactyl:latest

Importing the Egg

In the Pterodactyl Admin Panel:

Open Nests.

Create or select a Nest for FINAL FANTASY XI.

Choose Import Egg.

Upload egg-final-fantasy-xi-landsandboat.json.

Create a new server using the imported Egg.

Select landsandboat-pterodactyl:latest as the runtime image.

Required allocations

Create allocations for the following ports on the Wings node:

Purpose

Port

Login configuration

51220

Login view

54001

Search

54002

Map and zone traffic

54230

Xiloader authentication

54231

Firewall rules and router port forwarding must match the allocations used by the server.

Database setup

Create a dedicated MariaDB database and user for LandSandBoat. Do not use the Pterodactyl Panel database account.

Configure these values in the server Startup tab:

Variable

Description

DB_HOST

MariaDB hostname or container name

DB_PORT

MariaDB port, normally 3306

DB_NAME

LandSandBoat database name

DB_USER

Dedicated LandSandBoat database user

DB_PASSWORD

Dedicated database password

PUBLIC_SERVER_IP

Address advertised to game clients

VER_LOCK

Client-version policy

After installation, initialize the empty LandSandBoat database once:

cd /home/container
.venv/bin/python3 tools/dbtool.py update full

For a completely new empty database, LandSandBoat's interactive database reset option may also be used. Database reset is destructive and must never be run against a server containing characters or account data.

Public server IP

PUBLIC_SERVER_IP is the IP address sent to the client after character selection.

Examples:

LAN-only server: use the Wings node LAN address, such as 10.0.0.4

Internet server: use the public IP reachable by players

A private address such as 127.0.0.1, 10.x.x.x, or 192.168.x.x will not work for remote internet players unless they are connected through a suitable VPN or routed private network.

The startup script updates all enabled rows in zone_settings so clients receive the correct map-server address instead of localhost.

Client version lock

VER_LOCK supports these values:

Value

Behaviour

0

Allow all client versions

1

Require the exact configured client version

2

Allow the configured version or newer

Allowing mismatched clients may cause gameplay, packet, or data incompatibilities. Updating the client to the version supported by the server is preferable.

Updating LandSandBoat

Before updating:

Stop the server.

Back up the database.

Back up custom Lua files and modules.

Update the selected branch, tag, or commit.

Rebuild the binaries.

Apply database updates.

Database update command:

cd /home/container
.venv/bin/python3 tools/dbtool.py update full

Database backup

Run the backup helper in an environment where the DB_* variables are available:

./scripts/backup-database.sh

The script creates a compressed SQL backup with a timestamped filename.

Validation

Validate the Egg JSON and shell-script syntax:

./scripts/validate-bundle.sh

Security notes

Never commit database passwords or .env files.

Use a dedicated database account with access only to the LandSandBoat database.

Do not expose MariaDB directly to the internet.

Restrict Pterodactyl Panel and Wings administrative access.

Back up the game database before upgrades or schema changes.

Review firewall and router rules before making the server public.

Disclaimer

This is an independent community deployment package and is not affiliated with, endorsed by, or sponsored by Square Enix, Pterodactyl, or the LandSandBoat project.

FINAL FANTASY XI and related names and assets are trademarks or copyrighted works of their respective owners. Users are responsible for complying with applicable licences, terms of service, and local laws.

Upstream projects

LandSandBoat server

Pterodactyl Panel and Wings

Please report LandSandBoat engine bugs to the upstream LandSandBoat project. Report packaging or Pterodactyl deployment issues in this repository.
