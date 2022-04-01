# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.
cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../android/src/libs/${ANDROID_ABI})

# Specifies a library name, specifies whether the library is STATIC or
# SHARED, and provides relative paths to the source code. You can
# define multiple libraries by adding multiple add_library() commands,
# and CMake builds them for you. When you build your app, Gradle
# automatically packages shared libraries with your APK.
add_library( # Specifies the name of the library.
        dart_native

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ../ios/common/include/dart_api_dl.c
        src/main/jni/dart_native.cpp
        src/main/jni/dn_method_helper.cc
        src/main/jni/dn_callback.cpp
        src/main/jni/dn_thread.cpp
        src/main/jni/dn_lifecycle_manager.cc
        src/main/jni/dn_method.cc
        src/main/jni/dn_jni_helper.cc
        src/main/jni/dn_dart_api.cc)

find_library( # Sets the name of the path variable.
        log-lib

        # Specifies the name of the NDK library that
        # you want CMake to locate.
        log)

target_link_libraries( # Specifies the target library.
        dart_native
        -landroid
        # Links the target library to the log library
        # included in the NDK.
        ${log-lib})

include_directories(../ios/common/include)