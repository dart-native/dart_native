//
// Created by Hui on 6/9/21.
//
#pragma once

#include <jni.h>
#include "dn_jni_env.h"

namespace dartnative {

template<typename T>
class JavaRef {
 public:
  explicit JavaRef(T obj) : obj_(obj) {}

  JavaRef() = default;

  ~JavaRef() = default;

  T Object() const { return static_cast<T>(obj_); }

  bool IsNull() const { return obj_ == nullptr; }

  JNIEnv *SetNewLocalRef(JNIEnv *env, jobject obj) {
    if (!env) {
      env = AttachCurrentThread();
    }
    if (obj)
      obj = env->NewLocalRef(obj);
    if (obj_)
      env->DeleteLocalRef(obj_);
    obj_ = obj;
    return env;
  }

  void SetNewGlobalRef(JNIEnv *env, jobject obj) {
    if (!env) {
      env = AttachCurrentThread();
    }
    if (obj)
      obj = env->NewGlobalRef(obj);
    if (obj_)
      env->DeleteGlobalRef(obj_);
    obj_ = obj;
  }

  void ResetLocalRef(JNIEnv *env) {
    if (obj_) {
      env->DeleteLocalRef(obj_);
      obj_ = nullptr;
    }
  }

  void ResetGlobalRef() {
    if (obj_) {
      AttachCurrentThread()->DeleteGlobalRef(obj_);
      obj_ = nullptr;
    }
  }

 protected:
  jobject obj_ = nullptr;

 private:
  JavaRef(const JavaRef &) = delete;
  JavaRef &operator=(const JavaRef &) = delete;
};

/**
 * Local reference will auto delete in destructor
 */
template<typename T>
class JavaLocalRef : public JavaRef<T> {
 public:
  JavaLocalRef() : env_(nullptr) {}

  /// Non-explicit copy constructor, to allow JavaLocalRef to be returned
  /// by value as this is the normal usage pattern.
  JavaLocalRef(const JavaLocalRef<T>& other) : env_(other.env_) {
    this->SetNewLocalRef(env_, other.obj_);
  }

  explicit JavaLocalRef(T obj, JNIEnv *env) : JavaRef<T>(obj), env_(env) {}

  ~JavaLocalRef() {
    this->Reset();
  }

  JavaLocalRef<T> &operator=(const JavaLocalRef<T> &other) {
    env_ = this->SetNewLocalRef(other.env_, other.obj_);
    return *this;
  }

  void Reset() { this->ResetLocalRef(env_); }

 private:
  JNIEnv *env_;
};

/**
 * Global reference will auto delete in destructor
 */
template<typename T>
class JavaGlobalRef : public JavaRef<T> {
 public:
  JavaGlobalRef() : env_(nullptr) {}

  explicit JavaGlobalRef(T obj, JNIEnv *env) : env_(env) { this->Reset(env, obj); }

  JavaGlobalRef(const JavaGlobalRef<T> &other) {
    this->Reset(other.env_, other.Object());
  }

  ~JavaGlobalRef() { this->Reset(); }

  void Reset() { this->ResetGlobalRef(); }

  template<typename U>
  void Reset(JNIEnv *env, U obj) {
    this->SetNewGlobalRef(env, obj);
  }

  JavaGlobalRef &operator=(const JavaGlobalRef& ref) {
    this->Reset(ref.env_, ref.Object());
    return *this;
  }

 private:
  JNIEnv *env_;
};

}