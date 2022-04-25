//
// Created by hui on 2022/4/25.
//
#pragma once

namespace dartnative {

void InitInterface(JNIEnv *env);

void *InterfaceWithName(char *name, JNIEnv *env);

void *InterfaceMetaData(char *name, JNIEnv *env);

void RegisterDartInterface(char *interface, char *method,
                           void *callback, Dart_Port dartPort);

}
