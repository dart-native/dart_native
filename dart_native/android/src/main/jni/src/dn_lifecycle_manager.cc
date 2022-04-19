#include <thread>
#include <unordered_map>
#include "dn_lifecycle_manager.h"
#include "dn_log.h"
#include "dn_jni_utils.h"

namespace dartnative {

/// key is jobject, value is pair which contain jclass and reference count
static std::unordered_map<jobject, int> object_global_reference;

/// protect object_global_reference
std::mutex global_reference_mtx;

/// check java object if in reference table
bool ObjectInReference(jobject globalObject) {
  std::lock_guard<std::mutex> lockGuard(global_reference_mtx);
  auto it = object_global_reference.find(globalObject);
  return it != object_global_reference.end();
}

/// retain java object
void RetainJObject(jobject globalObject) {
  std::lock_guard<std::mutex> lockGuard(global_reference_mtx);
  auto it = object_global_reference.find(globalObject);
  if (it == object_global_reference.end()) {
    object_global_reference[globalObject] = 1;
    return;
  }
  /// dart object retain this dart object
  /// reference++
  it->second += 1;
}

/// release java object
void ReleaseJObject(jobject globalObject) {
  std::lock_guard<std::mutex> lockGuard(global_reference_mtx);
  auto it = object_global_reference.find(globalObject);
  if (it == object_global_reference.end()) {
    DNError("ReleaseJObject error not contain this object!!!");
    return;
  }
  /// release reference--
  it->second -= 1;

  /// no dart object retained this native object
  if (it->second <= 0) {
    JNIEnv *env = AttachCurrentThread();
    object_global_reference.erase(it);
    env->DeleteGlobalRef(globalObject);
  }
}


}