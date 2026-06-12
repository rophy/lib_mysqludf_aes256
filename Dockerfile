ARG MARIADB_VERSION=10.6
FROM mariadb:${MARIADB_VERSION}

RUN apt-get update \
    && apt-get install -y make gcc libtool libmariadbd-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .

# Copy server headers to ./include/ so the configure hack finds them
RUN mkdir -p include && cp -r /usr/include/mariadb/server/* include/

# Stub mysql_config pointing to the server plugin directory
RUN printf '#!/bin/sh\ncase "$1" in\n  --version) mariadb_config --version;;\n  --plugindir) echo "/usr/lib/mysql/plugin";;\n  --include) echo "-I/build/include";;\nesac\n' > /usr/local/bin/mysql_config \
    && chmod +x /usr/local/bin/mysql_config

RUN ./configure && make && make install
