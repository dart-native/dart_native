import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/functions.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';
import 'package:dart_native/src/android/runtime/register.dart';
import 'package:dart_native/src/android/runtime/extension/jobject_extension.dart';
import 'package:dart_native/src/android/runtime/extension/jobject_async_extension.dart';
import 'package:dart_native/src/android/foundation/native_type.dart';

/// Use classname create a null pointer.
JObject createNullJObj(String clsName) {
  return JObject.fromPointer(nullptr.cast(), className: clsName);
}

/// Bind dart object lifecycle with native object.
void bindLifeCycleWithNative(JObject? obj) {
  if (initDartAPISuccess && obj != null && obj.pointer != nullptr) {
    passJObjectToC!(obj, obj.pointer.cast<Void>());
  } else {
    print('pass object to native failed! address=${obj?.pointer}');
  }
}

/// When invoke with async method, dart can set run thread.
enum Thread {
  /// Flutter UI thread.
  FlutterUI,

  /// Native main thread.
  MainThread,

  /// Native sub thread.
  SubThread
}

/// Class [JObject] is the root of the java class hierarchy in dart.
/// Every dart class need has [JObject] as a superclass. All objects,
/// including arrays, invoke all native method use [invoke] from this.
class JObject {
  /// Java object pointer.
  late Pointer<Void> _ptr;

  Pointer<Void> get pointer {
    return _ptr;
  }

  /// Java class name.
  late String? _cls;

  String? get clsName {
    return _cls;
  }

  /// Default constructor. Create java object.
  ///
  /// [args] constructor argument.
  /// Dart basic type not equal as java basic type, such as dart not contain byte, short, long, float.
  /// But the parameter list need same as java method parameter list.
  /// If java method parameter list contain like byte, short, you need use wrapper class is dart.
  /// See [float], [byte], [short], [jchar], [long].
  /// For example:
  /// Java class:
  /// class Test {
  ///   Test(int i, byte b, short s);
  /// }
  /// dart class:
  /// @nativeJavaClass(className: "com/test/Test")
  /// class Test extend JObject {
  ///   Test(int i, int b, int s): super(args: [i, byte[b], short[s]);
  /// }
  ///
  /// [isInterface] java class if is a interface class.
  /// [className] use @nativeJavaClass first in your dart class.
  JObject({List? args, bool isInterface = false, String? className}) {
    _cls = className != null
        ? className
        : getRegisterJavaClass(runtimeType.toString());
    if (_cls == null) {
      throw "Java class name is null, you can set java class name in constructor" +
          " or use @nativeJavaClass annotation";
    }
    _ptr = newObject(_cls!, this, args: args, isInterface: isInterface);
    bindLifeCycleWithNative(this);
  }

  /// Wrapper java object pointer as dart object.
  ///
  /// [className] use @nativeJavaClass first.
  JObject.fromPointer(Pointer<Void> pointer, {String? className}) {
    _cls = className != null
        ? className
        : getRegisterJavaClass(runtimeType.toString());
    if (_cls == null) {
      throw "Java class name is null, you can set java class name in constructor" +
          " or use @nativeJavaClass annotation";
    }
    _ptr = pointer;
    bindLifeCycleWithNative(this);
  }

  /// Invoke java method, you can use [JObjectInvoke] extension method which is more simplify.
  ///
  /// [returnType] java method return type, same as JNI signature.
  /// If java method return int, return type is 'I'. Full jni signature below here.
  /// Java type   |   Signature
  ///   int       |       I
  ///   byte      |       B
  ///   char      |       C
  ///   short     |       S
  ///   long      |       J
  ///   boolean   |       Z
  ///   float     |       F
  ///   double    |       D
  ///   void      |       V
  ///   class     |  L + classname + ;
  ///   String    | Ljava/lang/String;       (class example)
  ///   array     |       [type
  ///   int[]     |       [I                  (int example)
  ///   String[]  |       [Ljava/lang/String; (class example)
  ///
  /// Dart basic type not equal as java basic type, such as dart not contain byte, short, long, float.
  /// But the parameter list need same as java method parameter list.
  /// If java method parameter list contain like byte, short, you need use wrapper class is dart.
  /// See [float], [byte], [short], [jchar], [long].
  /// For example
  /// java method: void test(int i, byte b, short s, long l, char c, float f);
  /// dart: invoke('test', 'V', args: [i, byte(b), short(s), long(l), jchar(c), float(f)]);
  /// also you can write: [invokeVoid]('test', args: [i, byte(b), short(s), long(l), jchar(c), float(f)]);
  ///
  /// Besides if your arguments type need to be assigned, use assignedSignature.
  /// For example
  /// In java ArrayList: boolean add(Object object);
  /// dart:
  /// JObject(className: 'java/util/ArrayList').invokeBool('add', args: [JInteger(10)], assignedSignature: ['Ljava/lang/Object;'])
  dynamic invoke(String methodName, String returnType,
      {List? args, List<String>? assignedSignature}) {
    return invokeMethod(_ptr.cast<Void>(), methodName, args, returnType,
        assignedSignature: assignedSignature);
  }

  /// Async invoke java method, you can use [JObjectAsyncInvoke] extension method which is more simplify.
  ///
  /// Same arguments as [invoke].
  /// Beside that arguments, invoke thread can be assigned by using [thread].
  /// Default java thread [Thread.MainThread].
  Future<dynamic> invokeAsync(String methodName, String returnType,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.MainThread}) async {
    return invokeMethodAsync(_ptr.cast<Void>(), methodName, args, returnType,
        assignedSignature: assignedSignature, thread: thread);
  }
}
