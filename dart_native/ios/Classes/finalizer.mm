#import "finalizer.h"
#include <stddef.h>
#include <stdlib.h>
#include <sys/types.h>

static void RunFinalizer(void *isolate_callback_data,
                         Dart_WeakPersistentHandle handle,
                         void *peer) {
    NSLog(@"%p", peer);
}

void PassObjectToCUseDynamicLinking(Dart_Handle h, void *native_object) {
    Dart_NewWeakPersistentHandle_DL(h, reinterpret_cast<void *>(native_object), 64, RunFinalizer);
}

intptr_t InitDartApiDL(void *data) {
    return Dart_InitializeApiDL(data);
}
