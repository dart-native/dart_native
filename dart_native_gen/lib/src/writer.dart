import 'package:dart_native_gen/src/collector.dart';

enum ClassType {
  Java,
  OC,
  Null,
}

class Writer {
  Collector collector;
  ClassType type;

  Writer(this.collector, this.type);

  String write() {
    if (Collector.packageName == null || type == ClassType.Null) {
      return '';
    }
    if (type == ClassType.Java && collector.javaClasses.length == 0) {
      return '';
    }
    if (type == ClassType.OC && collector.ocClasses.length == 0) {
      return '';
    }

    String result = "import 'package:dart_native/dart_native.dart';";

    if (Collector.packageName == 'dart_native') {
      result += """
        bool _hadRanDartNative = false;
        bool get hadRanDartNative => _hadRanDartNative;

        """;
    } else {
      Set<String> importFiles = type == ClassType.Java
          ? collector.javaImportFiles
          : collector.ocImportFiles;
      result += importFiles.map((String importFile) {
        return "import '$importFile';";
      }).join('\n');
    }

    String functionName =
        generateFunctionName(Collector.packageName, type: type);
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

    if (type == ClassType.OC) {
      result += collector.ocClasses.map((String className) {
        return """
          registerTypeConvertor('$className', (ptr) {
            return $className.fromPointer(ptr);
          });
          """;
      }).join('\n');
    } else {
      collector.javaClasses.forEach((dartClass, javaClass) {
        result += """
          registerJavaTypeConvertor('$dartClass', '$javaClass', (ptr) {
            return $dartClass.fromPointer(ptr);
          });\n
          """;
      });
    }

    result += """
      }
      """;
    return result;
  }

  String writeEntry(String fileName) {
    if (Collector.packageName == null) {
      return '';
    }
    String result = '';
    bool hasOCClasses = collector.ocClasses.isNotEmpty;
    bool hasJavaClasses = collector.javaClasses.isNotEmpty;
    if (hasOCClasses && hasJavaClasses) {
      result += "import 'dart:io';\n";
    }
    if (hasOCClasses) {
      result += "import '$fileName.oc.dn.dart';\n";
    }
    if (hasJavaClasses) {
      result += "import '$fileName.java.dn.dart';\n";
    }

    String functionName = generateFunctionName(Collector.packageName);
    result += """
      void $functionName() {
      """;
    if (hasOCClasses && hasJavaClasses) {
      result += """
          Platform.isAndroid ? ${generateFunctionName(Collector.packageName, type: ClassType.Java)}() : ${generateFunctionName(Collector.packageName, type: ClassType.OC)}();
      """;
    } else if (hasOCClasses) {
      result += """
          ${generateFunctionName(Collector.packageName, type: ClassType.OC)}();
      """;
    } else if (hasJavaClasses) {
      result += """
          ${generateFunctionName(Collector.packageName, type: ClassType.Java)}();
      """;
    }
    result += """
      }
    """;

    return result;
  }
}

String generateFunctionName(String? packageName, {ClassType? type}) {
  String result = 'run' + (type?.toString().split('.').last ?? '');
  print('packageName: $packageName');
  result += packageName!.split('_').map((String s) {
    if (s.length == 1) {
      return s.toUpperCase();
    }
    return '${s[0].toUpperCase()}${s.substring(1)}';
  }).join();
  return result;
}
