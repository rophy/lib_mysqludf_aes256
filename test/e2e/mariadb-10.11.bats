#!/usr/bin/env bats

MARIADB_VERSION="10.11"

setup_file() {
    load helpers
    build_and_start "$MARIADB_VERSION"
}

teardown_file() {
    load helpers
    stop_and_remove "$MARIADB_VERSION"
}

setup() {
    load helpers
    load aes256-tests
}

@test "10.11: version info" { assert_version_info; }
@test "10.11: AES-128 round-trip" { assert_aes128_roundtrip; }
@test "10.11: AES-192 round-trip" { assert_aes192_roundtrip; }
@test "10.11: AES-256 round-trip" { assert_aes256_roundtrip; }
@test "10.11: known ciphertext stable" { assert_known_ciphertext; }
@test "10.11: decrypt invalid returns NULL" { assert_decrypt_invalid_returns_null; }
@test "10.11: empty string round-trip" { assert_empty_string_roundtrip; }
