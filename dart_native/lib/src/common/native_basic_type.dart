import 'dart:convert';

/// Stands for `char` in C.
// ignore: camel_case_types
typedef char = int;

extension Utf8String on char {
  String toUTF8String() {
    return utf8.decode([this]);
  }
}

/// Stands for `unsigned char` in C.
// ignore: camel_case_types
typedef unsigned_char = char;

/// Stands for `unsigned short` in C.
// ignore: camel_case_types
typedef unsigned_short = int;

/// Stands for `unsigned int` in C.
// ignore: camel_case_types
typedef unsigned_int = int;

/// Stands for `unsigned long` in C.
// ignore: camel_case_types
typedef unsigned_long = int;

/// Stands for `long long` in C.
// ignore: camel_case_types
typedef long_long = int;

/// Stands for `unsigned long long` in C.
// ignore: camel_case_types
typedef unsigned_long_long = int;

/// Stands for `size_t` in C.
// ignore: camel_case_types
typedef size_t = int;

/// Stands for `int8_t` in C.
// ignore: camel_case_types
typedef int8_t = int;

/// Stands for `int16_t` in C.
// ignore: camel_case_types
typedef int16_t = int;

/// Stands for `int32_t` in C.
// ignore: camel_case_types
typedef int32_t = int;

/// Stands for `int64_t` in C.
// ignore: camel_case_types
typedef int64_t = int;

/// Stands for `uint8_t` in C.
// ignore: camel_case_types
typedef uint8_t = int;

/// Stands for `uint16_t` in C.
// ignore: camel_case_types
typedef uint16_t = int;

/// Stands for `uint32_t` in C.
// ignore: camel_case_types
typedef uint32_t = int;

/// Stands for `uint64_t` in C.
// ignore: camel_case_types
typedef uint64_t = int;
