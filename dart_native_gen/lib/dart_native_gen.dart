class NativeClass {
  const NativeClass();
}

class JavaClass extends NativeClass {
  final String javaClass;
  const JavaClass(this.javaClass);
}

class NativeClassRoot {
  const NativeClassRoot();
}

const Object native = NativeClass();

const Object nativeRoot = NativeClassRoot();

// ignore: camel_case_types
typedef nativeJavaClass = JavaClass;
