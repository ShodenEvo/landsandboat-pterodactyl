# LandSandBoat Pterodactyl bundle

This repository provides a Pterodactyl Egg, installation script, runtime startup script, and gameplay-setting integration for running a LandSandBoat Final Fantasy XI server in a Pterodactyl-managed Docker container.

The package does **not** include Final Fantasy XI client files.

## Contents

- `egg-final-fantasy-xi-landsandboat.json` — Pterodactyl Egg definition
- `scripts/install.sh` — Pterodactyl installation script
- `scripts/start.sh` — runtime startup script
- `scripts/validate-map-settings.py` — validates exposed gameplay variables
- `MAP_STARTUP_VARIABLES.md` — reference for all exposed `map.lua` settings

## Application prerequisites

### Server hardware

Recommended minimum for a small private server:

- 64-bit x86 processor
- 4 CPU cores
- 8 GB RAM
- 30–50 GB free disk space
- Stable network connection
- Static LAN address for the Pterodactyl node

Allow more CPU, memory, and storage for additional players, frequent builds, backups, logs, and database growth.

### Required server software

A working deployment requires:

- Pterodactyl Panel
- Pterodactyl Wings on a supported Linux node
- Docker Engine on the Wings node
- MariaDB or MySQL-compatible database
- Access to the configured LandSandBoat runtime image
- DNS resolution from inside the game container
- Router and firewall access for the game ports

Pterodactyl Wings requires Linux and does not run natively on Windows. A Windows machine must use a Linux virtual machine, WSL2-based test environment, or a separate Linux Wings node.

Official references:

- [Pterodactyl Panel installation](https://pterodactyl.io/panel/1.0/getting_started.html)
- [Pterodactyl Wings installation](https://pterodactyl.io/wings/1.0/installing)
- [Docker Engine installation](https://docs.docker.com/engine/install/)

### Database requirements

Use a dedicated MariaDB or MySQL database and user. The account must be able to create and modify the LandSandBoat schema.

Required Startup variables:

```text
DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
```

When the database runs in another Docker container, use the database container name or network hostname. Do not use `127.0.0.1`, because that refers to the game container itself.

The database must be reachable from the Wings-managed game container through a shared Docker network or another trusted internal network.

### Docker image

The Wings node must be able to pull the image configured in the Egg, for example:

```text
shoden/landsandboat-pterodactyl:latest
```

A private registry requires valid registry credentials on the Wings node.

### Network ports

Create Pterodactyl allocations and permit the following ports through Docker, the host firewall, the router, and any cloud firewall:

```text
51220
54001
54002
54230
54231
```

For a simple deployment, allow and forward both TCP and UDP for all five ports unless you have tested a narrower protocol configuration.

### Public address

`PUBLIC_SERVER_IP` accepts either:

- a public IPv4 address, or
- a DNS hostname that resolves to a public IPv4 address

Example:

```text
PUBLIC_SERVER_IP=<your-public-hostname>
```

At startup, the script resolves the hostname and writes the numeric IPv4 address into `zone_settings.zoneip`. That is the address sent to clients after character selection.

Dynamic DNS is supported, but the game server must be restarted after the public address changes.

### File permissions

The runtime user must be able to read and modify:

```text
settings/network.lua
settings/login.lua
settings/map.lua
pterodactyl/start.sh
```

The startup script must be executable:

```bash
chmod 755 pterodactyl/start.sh
```

Pterodactyl normally manages server-volume ownership. Manually copied files may require ownership correction for the container UID and GID used by the runtime image.

### Client prerequisites

Each player needs:

- a valid Final Fantasy XI installation
- a compatible private-server launcher such as the current `xiloader`
- the server hostname or public IP
- the correct login port
- a client version compatible with the LandSandBoat build

`VER_LOCK` controls version validation:

```text
0 = accept any client version
1 = require an exact version
2 = accept equal or newer versions
```

Use `0` during initial testing only when needed.

---

# Deployment — Linux

Linux is the recommended and supported production environment.

## Linux prerequisites

Recommended host operating systems include currently supported releases of Ubuntu, Debian, Rocky Linux, or AlmaLinux that are supported by Pterodactyl Wings.

Before deployment, confirm:

```bash
uname -m
docker --version
systemctl status docker
systemctl status wings
```

The system should be 64-bit, Docker should be active, and the Wings node should show as online in the Pterodactyl Panel.

Avoid unsupported container virtualization such as OpenVZ or unprivileged LXC unless the provider explicitly supports nested Docker. KVM or dedicated hardware is preferable.

## Linux deployment steps

### 1. Prepare Pterodactyl

Install and configure:

- Pterodactyl Panel
- Pterodactyl Wings
- Docker Engine
- a node and server allocations

The Panel and Wings may run on the same machine or on different machines.

### 2. Prepare MariaDB

Create:

- a dedicated database, such as `xidb`
- a dedicated database user
- a strong password
- network access from the game container

Do not expose the database port publicly unless absolutely necessary.

### 3. Import the Egg

In the Pterodactyl Admin Panel:

1. Open **Nests**.
2. Create or select a Nest.
3. Import `egg-final-fantasy-xi-landsandboat.json`.
4. Confirm the runtime Docker image.
5. Confirm the installation and startup commands.

### 4. Create the server

Assign:

- CPU and memory limits
- disk space
- all required port allocations
- the LandSandBoat Egg
- the database connection values

### 5. Configure Startup variables

At minimum, set:

```text
DB_HOST
DB_PORT
DB_NAME
DB_USER
DB_PASSWORD
PUBLIC_SERVER_IP
VER_LOCK
MAP_PORT
SEARCH_PORT
LOGIN_DATA_PORT
LOGIN_VIEW_PORT
LOGIN_AUTH_PORT
LOGIN_CONF_PORT
```

The Egg also exposes 107 gameplay values from `settings/map.lua`.

Boolean values must be lowercase:

```text
true
false
```

### 6. Install or reinstall

Use **Reinstall Server** in Pterodactyl. The install script prepares the LandSandBoat server files and runtime configuration.

### 7. Initialize the database

For an empty database, run the LandSandBoat database updater once from the server console or container shell:

```bash
cd /home/container
.venv/bin/python3 tools/dbtool.py update full
```

Back up an existing database before applying updates.

### 8. Start and verify

A successful startup should include messages similar to:

```text
Applied 107 gameplay settings to settings/map.lua
Resolved <your-public-hostname> to <public-ipv4>
```

Verify a gameplay value in the mounted server volume:

```bash
grep -nE '^\s*EXP_RATE\s*=' settings/map.lua
```

Verify that active zones use the public numeric address in `zone_settings`.

### 9. Configure firewall and router

Permit the five game ports on:

- the Linux host firewall
- the router or gateway
- the cloud-provider firewall, where applicable

Forward them to the static LAN address of the Wings node.

### 10. Connect a client

Configure the client launcher with the public hostname or public IPv4 address and the correct login port.

---

# Deployment — Windows

## Important support limitation

Pterodactyl Wings does not run natively on Windows. For a reliable production deployment, use one of these designs:

1. **Recommended:** Linux server or Linux virtual machine hosts Wings and the game server; Windows is used only for administration and the FFXI client.
2. **Testing option:** Windows 10/11 with WSL2 and Docker Desktop runs a Linux-based development environment.
3. **Windows Server option:** run a supported Linux VM under Hyper-V, VMware, or another hypervisor, then install Wings inside that Linux VM.

A Windows-only native Wings deployment is not supported.

## Windows administration workstation prerequisites

For managing a remote Linux deployment, install:

- a modern web browser for Pterodactyl
- an SSH client, such as Windows Terminal/OpenSSH
- an archive utility for ZIP files
- optional GitHub Desktop or the GitHub web editor
- the Final Fantasy XI client and compatible launcher for gameplay testing

No local Docker installation is required when Windows only administers a remote Linux node.

## Windows test deployment with WSL2

This configuration is suitable for development and controlled testing, not the preferred production topology.

### Windows prerequisites

- Windows 10 version 2004/build 19041 or later, or Windows 11
- hardware virtualization enabled in BIOS/UEFI
- WSL2
- Ubuntu or another compatible WSL Linux distribution
- Docker Desktop using the WSL2 backend
- at least 8 GB system RAM; more is recommended
- sufficient free disk space

Official references:

- [Install WSL](https://learn.microsoft.com/windows/wsl/install)
- [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
- [Docker Desktop WSL2 backend](https://docs.docker.com/desktop/features/wsl/)

### 1. Install WSL2

Open PowerShell as Administrator:

```powershell
wsl --install
```

Restart Windows when requested. Confirm WSL2:

```powershell
wsl --list --verbose
```

### 2. Install Docker Desktop

Install Docker Desktop and enable:

- **Use the WSL 2 based engine**
- integration with the selected Ubuntu distribution
- Linux containers

Store project and server files inside the WSL Linux filesystem rather than under `C:\` for better Linux-container filesystem performance.

### 3. Decide where Pterodactyl runs

For testing, you may run the Panel and related services inside WSL2 or in Docker containers, but Wings itself remains a Linux service and this topology can require additional networking and systemd configuration.

For simpler operation, use Windows only as the administration workstation and deploy Pterodactyl Wings on a separate Linux machine or Linux VM.

### 4. Deploy inside a Linux VM instead

For a Windows host intended to run continuously, a Linux VM is the clearer production-like design:

1. Enable Hyper-V or install another hypervisor.
2. Create an Ubuntu or Debian VM.
3. Assign a static LAN address to the VM.
4. Allocate at least 4 vCPUs, 8 GB RAM, and 50 GB disk.
5. Enable bridged or external networking.
6. Install Docker, Pterodactyl Wings, and the database in the Linux VM.
7. Follow the **Deployment — Linux** section.
8. Forward the game ports to the Linux VM, not to the Windows host address unless the hypervisor performs the required forwarding.

### 5. Windows firewall and NAT

When using WSL2 or a Linux VM, ensure the ports reach the Linux environment. Windows Defender Firewall, the hypervisor virtual switch, WSL networking, and the router may each require rules.

Because WSL2 networking can change between Windows releases and configurations, verify port reachability from another device before attempting an internet connection.

### 6. Windows client testing

Install and configure the FFXI client on Windows. Point the private-server launcher to:

- the Linux VM or WSL address for local testing, or
- the public hostname for external testing

When testing from the same LAN using the public hostname, the router must support NAT loopback/hairpin NAT. Otherwise, use split DNS or the internal Linux node address for local testing.

---

## Dynamic DNS and hostname support

`PUBLIC_SERVER_IP` accepts a literal IPv4 address or a hostname such as `<your-public-hostname>`.

At each startup:

1. the hostname is resolved to IPv4;
2. the numeric address is written to `zone_settings`;
3. the address is advertised to clients.

If resolution fails, startup stops instead of advertising an invalid address.

## Gameplay settings in Pterodactyl Startup

This release exposes **107 gameplay settings** from `settings/map.lua` as editable Pterodactyl Startup variables.

They include:

- experience and capacity rates
- skill-up and crafting rates
- movement and mount speed
- TP, HP, MP, and stat multipliers
- drop and gil rates
- auction-house behavior
- fishing and level sync
- subjob ratio
- battlefield rules
- auditing and logging options

The startup script validates and writes these values to `settings/map.lua` every time the server starts. Pterodactyl Startup values therefore override manual edits to the same entries in `map.lua`.

## Startup script correction

This package contains corrected Python regular expressions for `VER_LOCK` and all `settings/map.lua` variables. It fixes startup errors such as:

```text
Could not update VER_LOCK
Could not update LIGHTLUGGAGE_BLOCK
```

## Operational recommendations

- Back up MariaDB regularly.
- Back up the Pterodactyl server volume before upgrades.
- Keep the database on a private network.
- Use strong database credentials.
- Configure log rotation.
- Monitor disk usage and database growth.
- Use a UPS for on-premises servers.
- Restart the game server after a dynamic public IP change.
- Test updates in a separate server before applying them to production.

## Readiness checklist

```text
[ ] Supported Linux Wings node is available
[ ] Pterodactyl Panel is operational
[ ] Wings node is online
[ ] Docker is operational
[ ] MariaDB is reachable from the game container
[ ] LandSandBoat Egg is imported
[ ] Runtime image is accessible
[ ] Required ports are allocated
[ ] Host and router firewalls permit the ports
[ ] PUBLIC_SERVER_IP resolves to public IPv4
[ ] Database credentials are valid
[ ] LandSandBoat schema is initialized
[ ] All required Startup variables have values
[ ] Server files are writable by the container user
[ ] Client is installed and configured
```
