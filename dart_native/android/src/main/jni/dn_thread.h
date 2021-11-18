//
// Created by Hui on 16/11/21.
//
#pragma once
#include <android/looper.h>
#include <array>

namespace dartNative {

/**
 * @brief When invoke with async method, dart can set run thread.
 *        [kFlutterUI] is default
 * */
enum class TaskRunnerType {
  /// invoke method run on flutter UI thread
  kFlutterUI,

  /// invoke method run on native main thread
  kNativeMain,

  /// invoke method run on sub thread
  kSub
};

class TaskRunner {
 public:
  static TaskRunner *GetInstance();

  TaskRunner();

  void ScheduleInvokeTask(TaskRunnerType type, std::function<void()> invoke);

 private:
  bool IsMainThread() const;
  void ScheduleTaskOnMainThread(std::function<void()> invoke);
  void ScheduleTaskOnSubThread(std::function<void()> invoke);

  ALooper* main_looper_ = nullptr;
  std::array<int, 2> fd_;
  int messagePipe[2];
};

}
