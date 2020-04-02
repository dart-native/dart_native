import 'package:flutter/material.dart';

import 'dart:ffi' as ffi;

import 'package:dart_native/src/android/dart_java.dart';

class AndroidApp extends StatefulWidget {
  @override
  _AndroidAppState createState() => _AndroidAppState();
}

class _AndroidAppState extends State<AndroidApp> {
  static final int _TEST_COUNT = 10000;

  int _ffiInt = 0;

  int _methodInt = 0;

  int _ffiDouble = 0;

  int _methodDouble = 0;

  int _methodString = 0;

  int _ffiByte = 0;

  int _ffiShort = 0;

  int _ffiLong = 0;

  int _ffiFloat = 0;

  int _ffiChar = 0;

  @override
  void initState() {
    super.initState();
  }

  static int currentTimeMillis() {
    return new DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Column(children: <Widget>[
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testIntMethodChannel();
                },
                child: Text('MethodChannel int : $_methodInt\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testDoubleMethodChannel();
                },
                child: Text('MethodChannel double : $_methodDouble\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testStringMethodChannel();
                },
                child: Text('MethodChannel string : $_methodString\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testIntFFI();
                },
                child: Text('FFI int : $_ffiInt\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testDoubleFFI();
                },
                child: Text('FFI double : $_ffiDouble\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testByteFFI();
                },
                child: Text('FFI byte : $_ffiByte\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testShortFFI();
                },
                child: Text('FFI short : $_ffiShort\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testLongFFI();
                },
                child: Text('FFI long : $_ffiLong\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testFloatFFI();
                },
                child: Text('FFI float : $_ffiFloat\n')),
          ),
        ),
        Expanded(
          child: new SizedBox(
            width: 800, // specific value
            child: new FlatButton(
                onPressed: () {
                  testCharFFI();
                },
                child: Text('FFI char : $_ffiChar\n')),
          ),
        ),
      ]),
    ));
  }

  void testIntMethodChannel() async {
    print("testIntMethodChannel");
    var startMs = currentTimeMillis();
    for (int i = 0; i < _TEST_COUNT; i++) {
      await DartJava.platformVersionInt;
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testIntMethodChannel ,cost ms :" + useMs.toString());
    setState(() {
      _methodInt = useMs;
    });
  }

  void testIntFFI() async {
    print("testIntFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final IntPlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeIntFunction>>("getPlatformInt")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testIntFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiInt = useMs;
    });
  }

  void testDoubleMethodChannel() async {
    print("testDoubleMethodChannel");
    var startMs = currentTimeMillis();
    for (int i = 0; i < _TEST_COUNT; i++) {
      await DartJava.platformVersionDouble;
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testDoubleMethodChannel ,cost ms :" + useMs.toString());
    setState(() {
      _methodDouble = useMs;
    });
  }

  void testStringMethodChannel() async {
    print("testStringMethodChannel");
    var startMs = currentTimeMillis();
    for (int i = 0; i < _TEST_COUNT; i++) {
      await DartJava.platformVersionString;
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testStringMethodChannel ,cost ms :" + useMs.toString());
    setState(() {
      _methodString = useMs;
    });
  }

  void testDoubleFFI() async {
    print("testDoubleFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final DoublePlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeDoubleFunction>>("getPlatformDouble")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testDoubleFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiDouble = useMs;
    });
  }

  void testByteFFI() async {
    print("testByteFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final BytePlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeByteFunction>>("getPlatformByte")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testByteFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiByte = useMs;
    });
  }

  void testShortFFI() async {
    print("testShortFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final ShortPlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeShortFunction>>("getPlatformShort")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testShortFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiShort = useMs;
    });
  }

  void testLongFFI() async {
    print("testLongFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final LongPlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeLongFunction>>("getPlatformLong")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testLongFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiLong = useMs;
    });
  }

  void testFloatFFI() async {
    print("testFloatFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final FloatPlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeFloatFunction>>("getPlatformFloat")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testFloatFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiFloat = useMs;
    });
  }

  void testCharFFI() async {
    print("testCharFFI");
    var startMs = currentTimeMillis();
    final ffi.DynamicLibrary nativePlatformLib =
    ffi.DynamicLibrary.open("libtest_lib.so");

    for (int i = 0; i < _TEST_COUNT; i++) {
      final CharPlatformFunction nativePlatform = nativePlatformLib
          .lookup<ffi.NativeFunction<NativeCharFunction>>("getPlatformChar")
          .asFunction();
      nativePlatform();
    }
    var endMs = currentTimeMillis();
    var useMs = endMs - startMs;
    print("testCharFFI ,cost ms :" + useMs.toString());
    setState(() {
      _ffiChar = useMs;
    });
  }
}

typedef IntPlatformFunction = int Function();
typedef NativeIntFunction = ffi.Int32 Function();

typedef DoublePlatformFunction = double Function();
typedef NativeDoubleFunction = ffi.Double Function();

typedef BytePlatformFunction = int Function();
typedef NativeByteFunction = ffi.Int8 Function();

typedef ShortPlatformFunction = int Function();
typedef NativeShortFunction = ffi.Int16 Function();

typedef LongPlatformFunction = int Function();
typedef NativeLongFunction = ffi.Int64 Function();

typedef FloatPlatformFunction = double Function();
typedef NativeFloatFunction = ffi.Float Function();

typedef CharPlatformFunction = int Function();
typedef NativeCharFunction = ffi.Uint16 Function();