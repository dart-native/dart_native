import 'package:dart_native/src/android/common/library.dart';

export 'runtime/jobject.dart';
export 'runtime/extension/jobject_extension.dart';
export 'runtime/extension/jobject_sync_extension.dart';
export 'runtime/pointer_convertor.dart';
export 'foundation/collection/jlist.dart';
export 'foundation/collection/jset.dart';
export 'foundation/collection/jarray.dart';
export 'foundation/collection/jmap.dart';
export 'foundation/wrapperclass/integer.dart';
export 'foundation/wrapperclass/boolean.dart';
export 'foundation/wrapperclass/byte.dart';
export 'foundation/wrapperclass/character.dart';
export 'foundation/wrapperclass/double.dart';
export 'foundation/wrapperclass/float.dart';
export 'foundation/wrapperclass/long.dart';
export 'foundation/wrapperclass/short.dart';
export 'foundation/wrapperclass/boxing_unboxing.dart';
export 'foundation/native_type.dart';
export 'common/callback_manager.dart';

Future<void> dartNativeInitCustomSoPath({String? soPath}) async {
  await initSoPath(soPath);
}
