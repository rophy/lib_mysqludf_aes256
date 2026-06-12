#!/usr/bin/env bats

VERSIONS=("10.6" "10.11" "11.4")

setup_file() {
    load helpers
    for v in "${VERSIONS[@]}"; do
        build_and_start "$v"
    done
}

teardown_file() {
    load helpers
    for v in "${VERSIONS[@]}"; do
        stop_and_remove "$v"
    done
}

setup() {
    load helpers
}

@test "cross-version: 10.6 encrypt → 10.11 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "10.6" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "10.11" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}

@test "cross-version: 10.6 encrypt → 11.4 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "10.6" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "11.4" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}

@test "cross-version: 10.11 encrypt → 10.6 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "10.11" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "10.6" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}

@test "cross-version: 10.11 encrypt → 11.4 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "10.11" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "11.4" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}

@test "cross-version: 11.4 encrypt → 10.6 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "11.4" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "10.6" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}

@test "cross-version: 11.4 encrypt → 10.11 decrypt" {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "11.4" "SELECT HEX(AES256_ENCRYPT('cross version test', '${key}'))")
    result=$(mysql_exec "10.11" "SELECT AES256_DECRYPT(UNHEX('${hex}'), '${key}')")
    [ "$result" = "cross version test" ]
}
