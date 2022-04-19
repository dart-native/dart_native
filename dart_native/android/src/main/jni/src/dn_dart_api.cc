#include "dn_dart_api.h"
#include "dn_log.h"

namespace dartnative {

/// notify dart run callback function
bool Notify2Dart(Dart_Port send_port, const DartWorkFunction *work) {
  const auto work_addr = reinterpret_cast<intptr_t>(work);

  Dart_CObject dart_object;
  dart_object.type = Dart_CObject_kInt64;
  dart_object.value.as_int64 = work_addr;

  const bool result = Dart_PostCObject_DL(send_port, &dart_object);
  if (!result) {
    DNError("Native callback to Dart failed! Invalid port or isolate died");
  }
  return result;
}

void NotifyJNIError() {

}

}
