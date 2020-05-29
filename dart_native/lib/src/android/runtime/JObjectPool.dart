import 'dart:collection';

import '../../../dart_native.dart';

class JObjectPool {
  static JObjectPool sInstance = new JObjectPool();

  var _pool = new SplayTreeMap();

  retain(JObject object) {
    var curCount = _pool[object];
    if (curCount == null) {
      _pool[object] = 1;
    } else {
      _pool[object] = curCount + 1;
    }
  }

  bool release(JObject object) {
    var curCount = _pool[object];
    if (curCount == null) {
      throw new Exception("release error , object has been released");
    } else {
      curCount--;
      if (curCount <= 0) {
        _pool.remove(object);
        return true;
      } else {
        _pool[object] = curCount;
        return false;
      }
    }
  }
}
