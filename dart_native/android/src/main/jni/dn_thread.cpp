//
// Created by Hui on 16/11/21.
//
#include <unistd.h>
#import "dn_thread.h"
#import "dn_log.h"

namespace dartNative {

TaskRunner *runner = nullptr;

/// this will be called on main thread
static int LooperCallback(int fd, int events, void* data) {
  DNDebug("LooperCallback");
  std::function<void()> *invoke = nullptr;
  if (read(fd, &invoke, sizeof(invoke)) != -1) {
    std::unique_ptr<std::function<void()>> pl{invoke};
    (*pl)();
  }
  return 1;
}

TaskRunner *TaskRunner::GetInstance() {
  if (runner == nullptr) {
    runner = new TaskRunner();
  }
  return nullptr;
}

TaskRunner::TaskRunner() {
  main_looper_ = ALooper_forThread();
  if (main_looper_ == nullptr) {
    DNError("fail to get main looper");
    return;
  }
  if (pipe(fd_.data()) == -1) {
    DNError("fail in pipe");
    return;
  }
  ALooper_acquire(main_looper_);
  if (ALooper_addFd(main_looper_, fd_[0], ALOOPER_POLL_CALLBACK, ALOOPER_EVENT_INPUT,
                    LooperCallback, nullptr) == -1) {
    return;
  }
}

void TaskRunner::ScheduleInvokeTask(TaskRunnerType type, std::function<void()> invoke) {
  switch (type) {
    case TaskRunnerType::kNativeMain:
      ScheduleTaskOnMainThread(std::move(invoke));
      break;
    case TaskRunnerType::kSub:
      ScheduleTaskOnSubThread(std::move(invoke));
      break;
    default:
      invoke();
      break;
  }

}

void TaskRunner::ScheduleTaskOnMainThread(std::function<void()> invoke) {
  DNDebug("ScheduleTaskOnMainThread start %d", main_looper_ == nullptr);
//  DNDebug("%d", fd_.size());
//  DNDebug("%d", fd_[0]);
//  DNDebug("%d", fd_[1]);
//  if (IsMainThread()) {
//    DNDebug("ScheduleTaskOnMainThread true %d");
//    invoke();
//  } else {
//    DNDebug("ScheduleTaskOnMainThread faslse %d", invoke == nullptr);
//    auto cb_ptr = std::make_unique<std::function<void()>>(std::move(invoke));
//  DNDebug("ScheduleTaskOnMainThread cb_ptr %d", invoke == nullptr);
//    auto raw_cb_ptr = cb_ptr.release();
//  DNDebug("ScheduleTaskOnMainThread release %d", invoke == nullptr);
    if (write(fd_[1], &invoke, sizeof(invoke)) == -1) {
      DNError("ScheduleMainThreadTasks invoke error");
    }
//  }

}
void TaskRunner::ScheduleTaskOnSubThread(std::function<void()> invoke) {

}
bool TaskRunner::IsMainThread() const {
  DNDebug("IsMainThread %d", main_looper_ == nullptr);
  auto current_looper = ALooper_forThread();
  if (current_looper == nullptr) {
    DNDebug("current_looper is null");
    return false;
  }
  DNDebug("current_looper is %d", main_looper_ == nullptr);
  return current_looper == main_looper_;
}

}
