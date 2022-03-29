#pragma once

#include <dart_api_dl.h>
#include <functional>

namespace dartnative {

typedef std::function<void()> DartWorkFunction;

bool Notify2Dart(Dart_Port send_port, const DartWorkFunction *work);

}
