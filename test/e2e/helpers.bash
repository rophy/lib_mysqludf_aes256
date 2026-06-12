IMAGE_NAME="lib-mysqludf-aes256"
PROJECT_ROOT="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)"

_container_name() {
    echo "${IMAGE_NAME}-${1//\./-}"
}

build_and_start() {
    local version="$1"
    local name
    name=$(_container_name "$version")
    local log="${BATS_FILE_TMPDIR}/docker-build-${version}.log"

    docker build --build-arg MARIADB_VERSION="$version" \
        -t "${IMAGE_NAME}:${version}" "$PROJECT_ROOT" > "$log" 2>&1 \
        || { cat "$log" >&2; return 1; }

    docker rm -f "$name" 2>/dev/null || true
    docker run -d --name "$name" \
        -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 \
        "${IMAGE_NAME}:${version}" >/dev/null

    _wait_for_ready "$name"
}

_wait_for_ready() {
    local name="$1"
    for i in $(seq 1 60); do
        if docker logs "$name" 2>&1 | grep -q "port.*3306"; then
            docker exec "$name" mariadb -u root -e "SELECT 1" >/dev/null 2>&1 && return 0
        fi
        sleep 1
    done
    echo "MariaDB container '$name' failed to become ready" >&2
    docker logs "$name" >&2
    return 1
}

stop_and_remove() {
    local version="$1"
    docker rm -f "$(_container_name "$version")" 2>/dev/null || true
}

mysql_exec() {
    local version="$1"
    local sql="$2"
    docker exec "$(_container_name "$version")" mariadb -u root -N -B -e "$sql" 2>&1
}
