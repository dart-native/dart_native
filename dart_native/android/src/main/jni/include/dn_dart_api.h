#pragma once
#include <functional>
#include "dart_api_dl.h"

namespace dartnative {

typedef std::function<void()> WorkFunction;

// Notify dart to run work function.
bool Notify2Dart(Dart_Port send_port, const WorkFunction *work);

}
