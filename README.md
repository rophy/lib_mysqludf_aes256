lib_mysqludf_aes256
===
[![GitHub license](https://img.shields.io/badge/license-GPLv2-blue.svg)](https://raw.githubusercontent.com/Joungkyun/lib_mysqludf_aes256/master/COPYING)

Support AES 128/192/256 encrypt and decrypt on MySQL and Maraidb with User Defined Function.

## License

Copyright (c) 2020 JoungKyun.Kim &lt;http://oops.org&gt; All rights reserved.
This program is under [GPL v2](License)

## Requirements

MariaDB 10.6 / 10.11 / 11.4 (tested in CI)

## Usage

 * AES 128 encrypt and decrypt
   * key length : 16byte
   * If the length of the key is 16byte, AES256_ENCRYPT will operate in the same way as AES_ENCRYPT.
```mysql
mysql> select HEX(AES256_ENCRYPT('strings', '0123456789abcdef'));
mysql> select AES256_DECRYPT(UNHEX('encrypted_hash_string'), '0123456789abcdef');
```

 * AES 192 encrypt and decrypt
   * key length : 24byte
```mysql
mysql> select HEX(AES256_ENCRYPT('strings', '0123456789abcdef01234567'));
mysql> select AES256_DECRYPT(UNHEX('encrypted_hash_string'), '0123456789abcdef01234567');
```

 * AES 256 encrypt and decrypt
   * key length : 32byte
```mysql
mysql> select HEX(AES256_ENCRYPT('strings', '0123456789abcdef0123456789abcdef'));
mysql> select AES256_DECRYPT(UNHEX('encrypted_hash_string'), '0123456789abcdef0123456789abcdef');
```

## Building

### Docker (recommended)

```bash
# Build for default MariaDB version (10.6)
make build

# Build for a specific version
make build MARIADB_VERSION=11.4

# Build and run tests
make test MARIADB_VERSION=10.6
```

### From source

```bash
./scripts/download-headers.sh <mariadb-version>
./configure
make
make install
```

### Register UDF functions

```bash
mysql < docs/aes256_install.sql
```

### Unregister UDF functions

```bash
mysql < docs/aes256_uninstall.sql
```

## Language API

This UDF function will operate in the same way with follow apis:

  * [javascript mysqlAES package](http://mirror.oops.org/pub/oops/javascript/mysqlAES/)
  * [PHP mysqlAES class](https://github.com/OOPS-ORG-PHP/mysqlAES)

## Credits

JoungKyun.Kim
