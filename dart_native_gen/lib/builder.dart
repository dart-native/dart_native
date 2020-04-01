import 'package:build/build.dart';
import 'package:dart_native_gen/src/type_generator.dart';
import 'package:source_gen/source_gen.dart';

Builder typeBuilder(BuilderOptions options) => LibraryBuilder(TypeGenerator(),
    generatedExtension: '.dart_native_invalid.dart');

Builder typeWriteBuilder(BuilderOptions options) =>
    LibraryBuilder(DartNativeGenerator(), generatedExtension: '.dn.dart');
