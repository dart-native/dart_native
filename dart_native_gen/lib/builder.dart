import 'package:build/build.dart';
import 'package:dart_native_gen/type_marker.dart';
import 'package:source_gen/source_gen.dart';

Builder typeConvertor(BuilderOptions options) => SharedPartBuilder([TypeGenerator()], 'type_convertor');