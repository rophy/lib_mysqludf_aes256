#!/usr/bin/env bats

CONTAINER_NAME="${CONTAINER_NAME:-lib-mysqludf-aes256-test}"

mysql_exec() {
    docker exec "$CONTAINER_NAME" mariadb -u root -N -B -e "$1" 2>&1
}

@test "lib_mysqludf_aes256_info returns version" {
    result=$(mysql_exec "SELECT lib_mysqludf_aes256_info()")
    [ -n "$result" ]
    [[ "$result" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "AES-128 round-trip (16-byte key)" {
    key="0123456789abcdef"
    plaintext="hello world"
    result=$(mysql_exec "SELECT AES256_DECRYPT(AES256_ENCRYPT('${plaintext}', '${key}'), '${key}')")
    [ "$result" = "$plaintext" ]
}

@test "AES-192 round-trip (24-byte key)" {
    key="0123456789abcdef01234567"
    plaintext="hello world"
    result=$(mysql_exec "SELECT AES256_DECRYPT(AES256_ENCRYPT('${plaintext}', '${key}'), '${key}')")
    [ "$result" = "$plaintext" ]
}

@test "AES-256 round-trip (32-byte key)" {
    key="0123456789abcdef0123456789abcdef"
    plaintext="hello world"
    result=$(mysql_exec "SELECT AES256_DECRYPT(AES256_ENCRYPT('${plaintext}', '${key}'), '${key}')")
    [ "$result" = "$plaintext" ]
}

@test "AES-256 known ciphertext is stable" {
    key="0123456789abcdef0123456789abcdef"
    plaintext="test_cross_version"
    hex=$(mysql_exec "SELECT HEX(AES256_ENCRYPT('${plaintext}', '${key}'))")
    [ -n "$hex" ]
    [ "$hex" = "604C1DC51E43381FC50AF7F1068294592D9F1BFC58D219448390EF18D79BB3B7" ]
}

@test "decrypt of invalid data returns NULL" {
    key="0123456789abcdef0123456789abcdef"
    result=$(mysql_exec "SELECT AES256_DECRYPT('not_encrypted_data_padding!', '${key}')")
    [ "$result" = "NULL" ]
}

@test "round-trip with empty string" {
    key="0123456789abcdef0123456789abcdef"
    result=$(mysql_exec "SELECT AES256_DECRYPT(AES256_ENCRYPT('', '${key}'), '${key}')")
    [ "$result" = "" ]
}
