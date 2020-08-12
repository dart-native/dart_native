#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>

#include "../include/dart_api.h"
#include "../include/dart_native_api.h"

#include "../include/dart_api_dl.h"

static void RunFinalizer(void* isolate_callback_data,
                         Dart_WeakPersistentHandle handle,
                         void* peer) {
  
}

// Tests that passing handles through FFI calls works, and that the FFI call
// sets up the VM state etc. correctly so that the handle API calls work.
//DART_EXPORT Dart_Handle PassObjectToC(Dart_Handle h) {
//  // Can use "h" until this function returns.
//
//  // A persistent handle which outlives this call. Lifetime managed in C.
//  auto persistent_handle = Dart_NewPersistentHandle(h);
//
//  Dart_Handle handle_2 = Dart_HandleFromPersistent(persistent_handle);
//  Dart_DeletePersistentHandle(persistent_handle);
//  if (Dart_IsError(handle_2)) {
//    Dart_PropagateError(handle_2);
//  }
//
//  Dart_Handle return_value;
//  if (!Dart_IsNull(h)) {
//    // A weak handle which outlives this call. Lifetime managed in C.
//    auto weak_handle = Dart_NewWeakPersistentHandle(
//        h, reinterpret_cast<void*>(0x1234), 64, RunFinalizer);
//    return_value = Dart_HandleFromWeakPersistent(weak_handle);
//
//    // Deleting a weak handle is not required, it deletes itself on
//    // finalization.
//    // Deleting a weak handle cancels the finalizer.
//    Dart_DeleteWeakPersistentHandle(weak_handle);
//  } else {
//    return_value = h;
//  }
//
//  return return_value;
//}

DART_EXPORT Dart_Handle PassObjectToCUseDynamicLinking(Dart_Handle h) {
  auto persistent_handle = Dart_NewPersistentHandle_DL(h);

  Dart_Handle handle_2 = Dart_HandleFromPersistent_DL(persistent_handle);
  Dart_SetPersistentHandle_DL(persistent_handle, h);
  Dart_DeletePersistentHandle_DL(persistent_handle);

  auto weak_handle = Dart_NewWeakPersistentHandle_DL(
      handle_2, reinterpret_cast<void*>(0x1234), 64, RunFinalizer);
  Dart_Handle return_value = Dart_HandleFromWeakPersistent_DL(weak_handle);

  Dart_DeleteWeakPersistentHandle_DL(weak_handle);

  return return_value;
}
