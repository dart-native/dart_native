# Sets the minimum version of CMake required to build your native library.
# This ensures that a certain set of CMake features is available to
# your build.
cmake_minimum_required(VERSION 3.4.1)
set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -s")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/../android/src/libs/${ANDROID_ABI})

file(GLOB_RECURSE JNI_SRC src/main/jni/src/**)
file(GLOB_RECURSE DART_SRC ../ios/common/include/dart_api_dl.c)
include_directories(src/main/jni src/main/jni/include ../ios/common/include)

# Specifies a library name, specifies whether the library is STATIC or
# SHARED, and provides relative paths to the source code. You can
# define multiple libraries by adding multiple add_library() commands,
# and CMake builds them for you. When you build your app, Gradle
# automatically packages shared libraries with your APK.
add_library(dart_native SHARED ${DART_SRC} ${JNI_SRC})

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