//
// Created by Hui on 6/9/21.
//

#ifndef DART_NATIVE_JNI_OBJECT_REF_H
#define DART_NATIVE_JNI_OBJECT_REF_H

#include <jni.h>

/**
 * Global reference will auto delete in destructor
 */
template <typename T>
class JavaGlobalRef {
 public:
  explicit JavaGlobalRef(T obj, JNIEnv *env): env_(env) {
    this->obj_ = env->NewGlobalRef(obj);
  }

  JavaGlobalRef() = delete;

  T Object() const { return static_cast<T>(obj_); }

  ~JavaGlobalRef() { this->DeleteGlobalRef(); }

 protected:
  jobject obj_ = nullptr;

 private:
  JNIEnv *env_;

  void DeleteGlobalRef() {
    if (this->obj_) {
      env_->DeleteGlobalRef(this->obj_);
      this->obj_ = nullptr;
    }
  }
};

#endif //DART_NATIVE_JNI_OBJECT_REF_H
