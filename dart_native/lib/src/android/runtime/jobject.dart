import 'dart:ffi';

import 'package:dart_native/dart_native.dart';
import 'package:dart_native/src/android/common/library.dart';
import 'package:dart_native/src/android/runtime/messenger.dart';

/// Convert java object pointer to dart object which extends [JObject].
typedef ConvertorToDartFromPointer = dynamic Function(Pointer<Void> ptr);

/// Use classname create a null pointer.
JObject createNullJObj(String clsName) {
  return JObject.fromPointer(nullptr.cast(), className: clsName);
}

/// When invoke with async method, dart can set run thread.
enum Thread {
  /// Flutter UI thread.
  flutterUI,

  /// Native main thread.
  mainThread,

  /// Native sub thread.
  subThread
}

/// Class [JObject] is the root of the java class hierarchy in dart.
/// Every dart class need has [JObject] as a superclass. All objects,
/// including arrays, invoke all native method use [callMethodSync] from this.
class JObject extends NativeObject {
  /// Java object pointer.
  late Pointer<Void> _ptr;

  Pointer<Void> get pointer {
    return _ptr;
  }

  /// Java class name.
  late String? _cls;

  String? get className {
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
  /// @nativeJavaClass(className: 'com/test/Test')
  /// class Test extend JObject {
  ///   Test(int i, int b, int s): super(args: [i, byte[b], short[s]);
  /// }
  ///
  /// [isInterface] java class if is a interface class.
  ///
  /// If java class is specified by [className], we will use it first.
  /// Otherwise we will get className from [@nativeJavaClass] annotation's register.
  ///
  /// When use native class, please use [@nativeJavaClass] annotation first.
  JObject({List? args, bool isInterface = false, String? className}) {
    _cls = className ?? getRegisterJavaClass(runtimeType.toString());
    if (_cls == null) {
      throw 'Java class name is null, you can specify the java class name in constructor'
          ' or use @nativeJavaClass annotation to specify the java class';
    }
    _ptr = newObject(_cls!, this, args: args, isInterface: isInterface);
    bindLifeCycleWithJava(_ptr);
  }

  /// Wrapper java object pointer as dart object.
  ///
  /// When java object pointer is nullptr, must specify the java class name [className].
  ///
  /// When java object pointer is not nullptr, we will get java class name from jni.
  /// If java class is specified by [className], we will use it first.
  JObject.fromPointer(Pointer<Void> pointer, {String? className}) {
    if (pointer == nullptr && className == null) {
      throw 'Java object pointer and classname are null.'
          ' When java object pointer is nullptr, you must specify the java class name.';
    }
    _ptr = pointer;
    _cls = className ?? getJClassName(pointer);
    bindLifeCycleWithJava(_ptr);
  }

  /// Sync call java native method, you can use [JObjectSyncCallMethod] extension method which is more simplify.
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
  ///   String    | Ljava/lang/String;        (class example)
  ///   array     |     [type
  ///   int[]     |     [I                    (int example)
  ///   String[]  |  [Ljava/lang/String;      (class example)
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
  dynamic callMethodSync(String methodName, String returnType,
      {List? args, List<String>? assignedSignature}) {
    return invokeSync(_ptr.cast<Void>(), methodName, returnType,
        args: args, assignedSignature: assignedSignature);
  }

  /// Async call java method, you can use [JObjectCallMethod] extension method which is more simplify.
  ///
  /// Same arguments as [callMethodSync].
  /// Beside that arguments, invoke thread can be assigned by using [thread].
  /// Default java thread [Thread.mainThread].
  Future<dynamic> callMethod(String methodName, String returnType,
      {List? args,
      List<String>? assignedSignature,
      Thread thread = Thread.mainThread}) async {
    return invoke(_ptr.cast<Void>(), methodName, returnType,
        args: args, assignedSignature: assignedSignature, thread: thread);
  }
}
