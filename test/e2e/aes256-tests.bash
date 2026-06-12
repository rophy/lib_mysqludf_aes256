assert_version_info() {
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT lib_mysqludf_aes256_info()")
    [[ "$result" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

assert_aes128_roundtrip() {
    local key="0123456789abcdef"
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT AES256_DECRYPT(AES256_ENCRYPT('hello world', '${key}'), '${key}')")
    [ "$result" = "hello world" ]
}

assert_aes192_roundtrip() {
    local key="0123456789abcdef01234567"
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT AES256_DECRYPT(AES256_ENCRYPT('hello world', '${key}'), '${key}')")
    [ "$result" = "hello world" ]
}

assert_aes256_roundtrip() {
    local key="0123456789abcdef0123456789abcdef"
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT AES256_DECRYPT(AES256_ENCRYPT('hello world', '${key}'), '${key}')")
    [ "$result" = "hello world" ]
}

assert_known_ciphertext() {
    local key="0123456789abcdef0123456789abcdef"
    hex=$(mysql_exec "$MARIADB_VERSION" "SELECT HEX(AES256_ENCRYPT('test_cross_version', '${key}'))")
    [ "$hex" = "604C1DC51E43381FC50AF7F1068294592D9F1BFC58D219448390EF18D79BB3B7" ]
}

assert_decrypt_invalid_returns_null() {
    local key="0123456789abcdef0123456789abcdef"
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT AES256_DECRYPT('not_encrypted_data_padding!', '${key}')")
    [ "$result" = "NULL" ]
}

assert_empty_string_roundtrip() {
    local key="0123456789abcdef0123456789abcdef"
    result=$(mysql_exec "$MARIADB_VERSION" "SELECT AES256_DECRYPT(AES256_ENCRYPT('', '${key}'), '${key}')")
    [ "$result" = "" ]
}
