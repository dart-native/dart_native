//
// Created by Hui on 16/11/21.
//
#include <unistd.h>
#include <thread>
#import "dn_thread.h"
#import "dn_log.h"

namespace dartnative {

static std::unique_ptr<TaskRunner> g_task_runner = nullptr;

void InitTaskRunner() {
  g_task_runner = std::make_unique<TaskRunner>();
}

void ScheduleInvokeTask(TaskThread type, std::function<void()> invoke) {
  if (g_task_runner == nullptr) {
    return;
  }
  g_task_runner->ScheduleInvokeTask(type, invoke);
}

/// this will be called on main thread
static int LooperCallback(int fd, int events, void *data) {
  std::function<void()> *invoke = nullptr;
  if (read(fd, &invoke, sizeof(invoke)) != -1) {
    std::unique_ptr<std::function<void()>> pl{invoke};
    (*pl)();
  }
  return 1;
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

TaskRunner::~TaskRunner() {
  if (main_looper_) {
    ALooper_removeFd(main_looper_, fd_[0]);
    ALooper_release(main_looper_);
    close(fd_[0]);
    close(fd_[1]);
  }
}

void TaskRunner::ScheduleInvokeTask(TaskThread type, std::function<void()> invoke) {
  switch (type) {
    case TaskThread::kNativeMain:ScheduleTaskOnMainThread(std::move(invoke));
      break;
    case TaskThread::kSub:ScheduleTaskOnSubThread(std::move(invoke));
      break;
    case TaskThread::kFlutterUI:
    default:break;
  }
}

void TaskRunner::ScheduleTaskOnMainThread(std::function<void()> invoke) {
  if (IsMainThread()) {
    invoke();
  } else {
    auto cb_ptr = std::make_unique<std::function<void()>>(std::move(invoke));
    auto raw_cb_ptr = cb_ptr.release();
    if (write(fd_[1], &raw_cb_ptr, sizeof(raw_cb_ptr)) == -1) {
      DNError("ScheduleMainThreadTasks invoke error");
    }
  }
}

void TaskRunner::ScheduleTaskOnSubThread(std::function<void()> invoke) {
  std::thread subThread(invoke);
  subThread.detach();
}

bool TaskRunner::IsMainThread() const {
  auto current_looper = ALooper_forThread();
  if (current_looper == nullptr) {
    return false;
  }
  return current_looper == main_looper_;
}
}
