import 'dart:collection';

import '../../../dart_native.dart';

class JObjectPool {
  var pool = new SplayTreeMap();

  retain(JObject object) {
    var curCount = pool[object];
    if (curCount == null) {
      pool[object] = 1;
    } else {
      pool[object] = curCount + 1;
    }
  }

  release(JObject object) {
    var curCount = pool[object];
    if (curCount == null) {
      throw new Exception("release error , object has been released");
    } else {
      curCount--;
      if (curCount <= 0) {
        pool.remove(object);
        object.release();
      } else {}
    }
  }
}
