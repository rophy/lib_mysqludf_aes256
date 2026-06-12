#!/usr/bin/env bats

MARIADB_VERSION="11.4"

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

@test "11.4: version info" { assert_version_info; }
@test "11.4: AES-128 round-trip" { assert_aes128_roundtrip; }
@test "11.4: AES-192 round-trip" { assert_aes192_roundtrip; }
@test "11.4: AES-256 round-trip" { assert_aes256_roundtrip; }
@test "11.4: known ciphertext stable" { assert_known_ciphertext; }
@test "11.4: decrypt invalid returns NULL" { assert_decrypt_invalid_returns_null; }
@test "11.4: empty string round-trip" { assert_empty_string_roundtrip; }
