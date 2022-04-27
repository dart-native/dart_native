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

DN_EXTERN void ExecuteCallback(dartnative::WorkFunction *work_ptr);

/** interface */
DN_EXTERN void *InterfaceHostObjectWithName(char *name);

DN_EXTERN void *InterfaceAllMetaData(char *name);

DN_EXTERN void InterfaceRegisterDartInterface(char *interface, char *method,
                                              void *callback, Dart_Port dartPort,
                                              int32_t return_async);
