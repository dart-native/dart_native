//
// Created by hui on 2022/4/19.
//
#pragma once
#include "dn_dart_api.h"

#if defined(__cplusplus)
#define DN_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define DN_EXTERN extern __attribute__((visibility("default")))
#endif

/** init dart extension */
DN_EXTERN intptr_t InitDartApiDL(void *data);

/** bind lifecycle */
DN_EXTERN void PassObjectToCUseDynamicLinking(Dart_Handle h, void *objPtr);

DN_EXTERN void RegisterDartFinalizer(Dart_Handle h, void *callback, void *key, Dart_Port dartPort);

/** invoke native */
DN_EXTERN void *GetClassName(void *objectPtr);

DN_EXTERN void *CreateTargetObject(char *targetClassName,
                                   void **arguments,
                                   char **argumentTypes,
                                   int argumentCount,
                                   uint32_t stringTypeBitmask);

DN_EXTERN void *InvokeNativeMethod(void *objPtr,
                                   char *methodName,
                                   void **arguments,
                                   char **dataTypes,
                                   int argumentCount,
                                   char *returnType,
                                   uint32_t stringTypeBitmask,
                                   void *callback,
                                   Dart_Port dartPort,
                                   int thread,
                                   bool isInterface);

/** callback */
DN_EXTERN void RegisterNativeCallback(void *dartObject,
                                      char *clsName,
                                      char *funName,
                                      void *callback,
                                      Dart_Port dartPort);

/**
 * When using callback finish, callback must be unregistered by hand.
 * */
DN_EXTERN void UnregisterNativeCallback(void *dart_object);

/**
 * run workFunction in c++ side
 * */
DN_EXTERN void ExecuteCallback(dartnative::WorkFunction *work_ptr);

/** interface */
DN_EXTERN void *InterfaceHostObjectWithName(char *name);

DN_EXTERN void *InterfaceAllMetaData(char *name);

DN_EXTERN void InterfaceRegisterDartInterface(char *interface, char *method,
                                              void *callback, Dart_Port dartPort,
                                              int32_t return_async);

/**
 * Dart async invoke result.
 * */
DN_EXTERN void AsyncInvokeResult(int64_t response_id, void *result, char *result_type);

/**
 * DirectByteBuffer
 * */
DN_EXTERN void *NewDirectByteBuffer(void *data, int64_t size);

DN_EXTERN void *GetDirectByteBufferData(void *object);

DN_EXTERN int64_t GetDirectByteBufferSize(void *object);
