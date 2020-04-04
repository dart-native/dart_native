import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:dart_native_gen/src/collector.dart';
import 'package:dart_native_gen/src/writer.dart';
import 'package:dart_native_gen/dart_native_gen.dart';
import 'package:source_gen/source_gen.dart';

class TypeGenerator extends GeneratorForAnnotation<NativeClass> {
  static Collector collector = Collector();

  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    collector.collect(element, annotation, buildStep);
    return null;
  }
}

class DartNativeGenerator extends GeneratorForAnnotation<NativeClassRoot> {
  @override
  generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) {
    return Writer(TypeGenerator.collector).write();
  }
}
