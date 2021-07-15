import 'package:dart_native_gen/src/collector.dart';

class Writer {
  Collector collector;
  Writer(this.collector);

  String write() {
    if (Collector.packageName == null) {
      return '';
    }
    String result = "import 'package:dart_native/dart_native.dart';";
    result += collector.importFiles.map((String importFile) {
      return "import '$importFile';";
    }).join('\n');

    if (Collector.packageName == 'dart_native') {
      result += """
        bool _hadRanDartNative = false;
        bool get hadRanDartNative => _hadRanDartNative;

        """;
    }

    String functionName = generateFunctionName(Collector.packageName);
    result += """
      void $functionName() {
      """;

    if (Collector.packageName != 'dart_native') {
      result += """
        runDartNative();

        """;
    } else {
      result += """
        if (_hadRanDartNative) {
          return;
        }
        _hadRanDartNative = true;

      """;
    }

    result += collector.classes.map((String className) {
      return """
        registerTypeConvertor('$className', (ptr) {
          return $className.fromPointer(ptr);
        });
        """;
    }).join('\n');

    result += """
      }
      """;
    return result;
  }

  String generateFunctionName(String? packageName) {
    String result = 'run';
    print('packageName: $packageName');
    result += packageName!.split('_').map((String s) {
      if (s.length == 1) {
        return s.toUpperCase();
      }
      return '${s[0].toUpperCase()}${s.substring(1)}';
    }).join();
    return result;
  }
}
