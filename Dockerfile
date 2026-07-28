FROM debian:bookworm-slim
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends bash ca-certificates git curl build-essential cmake ninja-build pkg-config python3 python3-venv python3-pip libmariadb-dev libmariadb-dev-compat libzmq3-dev libluajit-5.1-dev libssl-dev zlib1g-dev libreadline-dev libncurses-dev libfmt-dev libyaml-cpp-dev libdwarf-dev binutils mariadb-client && rm -rf /var/lib/apt/lists/*
RUN groupadd -g 977 container && useradd -m -d /home/container -u 991 -g 977 -s /bin/bash container
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container
CMD ["/bin/bash","/home/container/pterodactyl/start.sh"]
COPY --chown=container:container scripts/start.sh /opt/lsb-bundle/start.sh
COPY --chown=container:container scripts/install.sh /opt/lsb-bundle/install.sh
