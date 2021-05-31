    # Sets the minimum version of CMake required to build your native library.
    # This ensures that a certain set of CMake features is available to
    # your build.

cmake_minimum_required(VERSION 3.4.1)

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
             src/main/jni/include/dart_api_dl.c
             src/main/jni/dart_native.cpp
             src/main/jni/dn_type_convert.cpp
             src/main/jni/dn_method_call.cpp)

    find_library( # Sets the name of the path variable.
            log-lib

            # Specifies the name of the NDK library that
            # you want CMake to locate.
            log )

    target_link_libraries( # Specifies the target library.
            dart_native

            # Links the target library to the log library
            # included in the NDK.
            ${log-lib} )

    include_directories(src/main/jni/include)