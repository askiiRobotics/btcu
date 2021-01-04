# Copyright (c) 2017 The Bitcoin developers

set(CMAKE_SYSTEM_NAME Darwin)
set(CMAKE_SYSTEM_PROCESSOR x86_64)
set(TOOLCHAIN_PREFIX ${CMAKE_SYSTEM_PROCESSOR}-apple-darwin16)

# On OSX, we use clang by default.
set(CMAKE_C_COMPILER clang)
set(CMAKE_CXX_COMPILER clang++)

set(CMAKE_C_COMPILER_TARGET ${TOOLCHAIN_PREFIX})
set(CMAKE_CXX_COMPILER_TARGET ${TOOLCHAIN_PREFIX})

set(OSX_MIN_VERSION 10.12)
# OSX_SDK_VERSION 10.15.1
# Note: don't use XCODE_VERSION, it's a cmake built-in variable !
set(SDK_XCODE_VERSION 11.3.1)
set(SDK_XCODE_BUILD_ID 11C505)
set(LD64_VERSION 530)

# On OSX we use various stuff from Apple's SDK.
set(OSX_SDK_PATH "${CMAKE_CURRENT_SOURCE_DIR}/depends/SDKs/Xcode-${SDK_XCODE_VERSION}-${SDK_XCODE_BUILD_ID}-extracted-SDK-with-libcxx-headers")
set(CMAKE_OSX_SYSROOT "${OSX_SDK_PATH}")
set(CMAKE_OSX_DEPLOYMENT_TARGET ${OSX_MIN_VERSION})
set(CMAKE_OSX_ARCHITECTURES x86_64)

# TODO: set downloaded SKD using
set(CMAKE_OSX_SYSROOT "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk")

# When cross-compiling for Darwin using Clang, -mlinker-version must be passed
# to ensure that modern linker features are enabled.
string(APPEND CMAKE_CXX_FLAGS_INIT " -stdlib=libc++ -mlinker-version=${LD64_VERSION}")

# Ensure we use an OSX specific version the binary manipulation tools.
find_program(CMAKE_AR ${TOOLCHAIN_PREFIX}-ar)
find_program(CMAKE_INSTALL_NAME_TOOL ${TOOLCHAIN_PREFIX}-install_name_tool)
find_program(CMAKE_LINKER ${TOOLCHAIN_PREFIX}-ld)
find_program(CMAKE_NM ${TOOLCHAIN_PREFIX}-nm)
find_program(CMAKE_OBJCOPY ${TOOLCHAIN_PREFIX}-objcopy)
find_program(CMAKE_OBJDUMP ${TOOLCHAIN_PREFIX}-objdump)
find_program(CMAKE_OTOOL ${TOOLCHAIN_PREFIX}-otool)
find_program(CMAKE_RANLIB ${TOOLCHAIN_PREFIX}-ranlib)
find_program(CMAKE_STRIP ${TOOLCHAIN_PREFIX}-strip)

# Path handling
# the RPATH to be used when installing
set(CMAKE_INSTALL_RPATH "/usr/local/lib")

