import 'package:analyzer/dart/element/element.dart';
import 'package:build/src/builder/build_step.dart';
import 'package:source_gen/source_gen.dart';
import 'package:dart_native/dart_native_annotation.dart';

class TypeGenerator extends GeneratorForAnnotation<NativeClass> {
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    var result = """
        class _${element.name} {
          _${element.name}() {
            registerTypeConvertor('${element.name}', (ptr) {
              return ${element.name}.fromPointer(ptr);
            });
          }
        }
        final _element = _${element.name}();
        """;
    return result;
  }
}