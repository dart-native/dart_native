#pragma once

#include <jni.h>

namespace dartnative {

bool ObjectInReference(jobject globalObject);

void RetainJObject(jobject globalObject);

void ReleaseJObject(jobject globalObject);

}
