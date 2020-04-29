# dart_native_gen

Annotation for dart_native.

## Description

Automatic type conversion solution for dart_native based on source_gen through annotation.

## Getting Started

1. Annotate a Dart wrapper class with `@native`.

```dart
@native
class RuntimeSon extends RuntimeStub {
  RuntimeSon([Class isa]) : super(Class('RuntimeSon'));
  RuntimeSon.fromPointer(Pointer<Void> ptr) : super.fromPointer(ptr);
}
```

2. Annotate your own entry class with `@nativeRoot`:

```dart
@nativeRoot
void main() {
  runDartNativeExample();
  runApp(Platform.isAndroid ? AndroidNewApp() : IOSApp());
}
```

3. just run the command below in your workspace
build:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

suggest you running the clean command before build:

```bash
flutter packages pub run build_runner clean
```

## Installation

add packages to dependencies in your pubspec.yaml
example:

```yaml
dependencies:
  dart_native_gen: any
```