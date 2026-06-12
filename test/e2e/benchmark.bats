#!/usr/bin/env bats

BENCH_ITERATIONS=100000

setup_file() {
    load helpers
    build_and_start "10.6"
}

teardown_file() {
    load helpers
    stop_and_remove "10.6"
}

setup() {
    load helpers
}

bench_encrypt_data() {
    local func="$1"
    local key="$2"
    local data="$3"
    local n="$BENCH_ITERATIONS"
    mysql_exec "10.6" "SET @d = '${data}'; SET @start = NOW(6); SELECT BENCHMARK(${n}, ${func}(@d, '${key}')); SELECT ROUND(${n} / (TIMESTAMPDIFF(MICROSECOND, @start, NOW(6)) / 1000000))" | tail -1
}

bench_decrypt_data() {
    local encrypt_func="$1"
    local decrypt_func="$2"
    local key="$3"
    local data="$4"
    local n="$BENCH_ITERATIONS"
    mysql_exec "10.6" "SET @data = ${encrypt_func}('${data}', '${key}'); SET @start = NOW(6); SELECT BENCHMARK(${n}, ${decrypt_func}(@data, '${key}')); SELECT ROUND(${n} / (TIMESTAMPDIFF(MICROSECOND, @start, NOW(6)) / 1000000))" | tail -1
}

@test "benchmark: 16B encrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data="hello world 1234"
    udf=$(bench_encrypt_data "AES256_ENCRYPT" "$key" "$data")
    builtin=$(bench_encrypt_data "AES_ENCRYPT" "$key" "$data")
    echo "# 16B encrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}

@test "benchmark: 16B decrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data="hello world 1234"
    udf=$(bench_decrypt_data "AES256_ENCRYPT" "AES256_DECRYPT" "$key" "$data")
    builtin=$(bench_decrypt_data "AES_ENCRYPT" "AES_DECRYPT" "$key" "$data")
    echo "# 16B decrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}

@test "benchmark: 1KB encrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data
    data=$(printf '%0.s0123456789abcdef' {1..64})
    udf=$(bench_encrypt_data "AES256_ENCRYPT" "$key" "$data")
    builtin=$(bench_encrypt_data "AES_ENCRYPT" "$key" "$data")
    echo "# 1KB encrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}

@test "benchmark: 1KB decrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data
    data=$(printf '%0.s0123456789abcdef' {1..64})
    udf=$(bench_decrypt_data "AES256_ENCRYPT" "AES256_DECRYPT" "$key" "$data")
    builtin=$(bench_decrypt_data "AES_ENCRYPT" "AES_DECRYPT" "$key" "$data")
    echo "# 1KB decrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}

@test "benchmark: 10KB encrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data
    data=$(printf '%0.s0123456789abcdef' {1..640})
    udf=$(bench_encrypt_data "AES256_ENCRYPT" "$key" "$data")
    builtin=$(bench_encrypt_data "AES_ENCRYPT" "$key" "$data")
    echo "# 10KB encrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}

@test "benchmark: 10KB decrypt ops/sec" {
    local key="0123456789abcdef0123456789abcdef"
    local data
    data=$(printf '%0.s0123456789abcdef' {1..640})
    udf=$(bench_decrypt_data "AES256_ENCRYPT" "AES256_DECRYPT" "$key" "$data")
    builtin=$(bench_decrypt_data "AES_ENCRYPT" "AES_DECRYPT" "$key" "$data")
    echo "# 10KB decrypt — UDF: ${udf} ops/sec | builtin: ${builtin} ops/sec" >&3
    [ "$udf" -gt 0 ]
}
