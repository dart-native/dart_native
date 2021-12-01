class NativeClass {
  final String? javaClass;
  const NativeClass({this.javaClass});
}

class NativeClassRoot {
  const NativeClassRoot();
}

const Object nativeRoot = NativeClassRoot();

// ignore: camel_case_types
typedef native = NativeClass;
