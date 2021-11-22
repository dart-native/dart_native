//
// Created by Hui on 16/11/21.
//
#pragma once
#include <android/looper.h>
#include <array>

#ifdef __cplusplus
extern "C"
{
#endif

/**
 * @brief When invoke with async method, dart can set run thread.
 *        [kFlutterUI] is default
 * */
enum TaskThread {
  /// invoke method run on flutter UI thread
  kFlutterUI,

  /// invoke method run on native main thread
  kNativeMain,

  /// invoke method run on sub thread
  kSub
};

class TaskRunner {
 public:
  TaskRunner();

  ~TaskRunner();

  void ScheduleInvokeTask(TaskThread thread, std::function<void()> invoke);

 private:
  bool IsMainThread() const;
  void ScheduleTaskOnMainThread(std::function<void()> invoke);
  void ScheduleTaskOnSubThread(std::function<void()> invoke);

  ALooper* main_looper_ = nullptr;
  std::array<int, 2> fd_;
};
#ifdef __cplusplus
}
#endif

