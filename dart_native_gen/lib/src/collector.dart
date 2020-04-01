import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

class Collector {
  Collector();
  
  static String packageName;
  Set<String> classes = Set();
  Set<String> importFiles = Set();

  void collect(
      ClassElement element, ConstantReader annotation, BuildStep buildStep) {
    final String className = element.name;
    classes.add(className);

    Collector.packageName = buildStep.inputId.package;

    if (buildStep.inputId.path.contains('.symlinks')) {
      return;
    }

    String path;
    if (buildStep.inputId.path.contains('lib/')) {
      path =
          "package:${buildStep.inputId.package}/${buildStep.inputId.path.replaceFirst('lib/', '')}";
    } else {
      path = "${buildStep.inputId.path}";
    }
    importFiles.add(path);
  }
}
