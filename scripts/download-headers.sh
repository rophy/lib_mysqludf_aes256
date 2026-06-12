#!/bin/bash
set -euo pipefail

# Download MariaDB server source headers for building UDF plugins.
#
# Usage:
#   ./scripts/download-headers.sh [VERSION]
#
# If VERSION is not provided, reads MARIADB_VERSION env var
# (format from MariaDB Docker image: "1:10.6.27+maria~ubu2204").

# Determine version
if [ $# -ge 1 ]; then
    FULL_VERSION="$1"
elif [ -n "${MARIADB_VERSION:-}" ]; then
    # Extract version from Docker env format: "1:10.6.27+maria~ubu2204" -> "10.6.27"
    FULL_VERSION=$(echo "$MARIADB_VERSION" | sed 's/^[0-9]*://; s/+.*//')
else
    echo "Error: No version provided. Pass as argument or set MARIADB_VERSION env var." >&2
    exit 1
fi

echo "MariaDB version: ${FULL_VERSION}"

# Skip if headers already downloaded
if [ -f "include/mysql_version.h" ]; then
    echo "Headers already exist (include/mysql_version.h found). Skipping download."
    exit 0
fi

# Parse version components
MAJOR=$(echo "$FULL_VERSION" | cut -d. -f1)
MINOR=$(echo "$FULL_VERSION" | cut -d. -f2)
PATCH=$(echo "$FULL_VERSION" | cut -d. -f3)

MARIADB_BRANCH="mariadb-${FULL_VERSION}"
TEMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Cloning MariaDB server headers (branch: ${MARIADB_BRANCH})..."
git clone --depth 1 --branch "${MARIADB_BRANCH}" \
    https://github.com/MariaDB/server.git "${TEMP_DIR}/server" \
    --no-checkout 2>&1
cd "${TEMP_DIR}/server"
git sparse-checkout set include
git checkout 2>&1
cd - > /dev/null

# Copy headers
mkdir -p include
cp -r "${TEMP_DIR}/server/include/"* include/

# Generate mysql_version.h from template
if [ -f "include/mysql_version.h.in" ]; then
    echo "Generating mysql_version.h from template..."
    MYSQL_VERSION_ID=$((MAJOR * 10000 + MINOR * 100 + PATCH))
    sed \
        -e "s/@MYSQL_VERSION_ID@/${MYSQL_VERSION_ID}/" \
        -e "s/@MAJOR_VERSION@/${MAJOR}/" \
        -e "s/@MINOR_VERSION@/${MINOR}/" \
        -e "s/@PATCH_VERSION@/${PATCH}/" \
        -e "s/@MYSQL_TCP_PORT@/3306/" \
        -e "s/@VERSION@/${FULL_VERSION}/" \
        -e "s/@PROTOCOL_VERSION@/10/" \
        -e "s/@MYSQL_UNIX_ADDR@/\/var\/run\/mysqld\/mysqld.sock/" \
        -e "s/@COMPILATION_COMMENT@/Source distribution/" \
        -e "s/@MYSQL_BASE_VERSION@/mariadb-${MAJOR}.${MINOR}/" \
        -e "s/@MYSQL_SERVER_SUFFIX@//" \
        -e "s/@MARIADB_BASE_VERSION@/mariadb-${MAJOR}.${MINOR}/" \
        -e "s/@MYSQL_VERSION_EXTRA@//" \
        -e "s/@MARIADB_VERSION_EXTRA@//" \
        -e "s/@MYSQL_TCP_PORT_DEFAULT@/0/" \
        -e "s/@DOT_FRM_VERSION@/6/" \
        -e "s/@SERVER_MATURITY_LEVEL@/MariaDB_PLUGIN_MATURITY_STABLE/" \
        -e "s/@WSREP_PATCH_VERSION@//" \
        include/mysql_version.h.in > include/mysql_version.h
    echo "Generated include/mysql_version.h"
else
    echo "Warning: mysql_version.h.in not found in source headers" >&2
fi

echo "Headers installed to include/"
