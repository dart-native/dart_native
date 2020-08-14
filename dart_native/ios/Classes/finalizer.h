#import "DNMacro.h"
#include "../common/include/dart_api_dl.h"

DN_EXTERN void PassObjectToCUseDynamicLinking(Dart_Handle h, void *native_object);
DN_EXTERN intptr_t InitDartApiDL(void *data);
