# ethash: C/C++ implementation of Ethash, the Ethereum Proof of Work algorithm.
# Copyright 2018 Pawel Bylica.
# Licensed under the Apache License, Version 2.0. See the LICENSE file.

cmake_minimum_required(VERSION 3.5)

if(POLICY CMP0069)
    cmake_policy(SET CMP0069 NEW)  # Allow LTO.
endif()

if(NOT ${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    target_include_directories(include)
endif()

include(cmake/cable/bootstrap.cmake)

include(CableBuildType)
include(CableCompilerSettings)
include(CableToolchains)

cable_configure_toolchain(DEFAULT cxx11)

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/google-benchmark)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/googletest)
else()
    include(HunterGate)

    if(NOT WIN32)
        # Outside of Windows build only Release packages.
        set(HUNTER_CONFIGURATION_TYPES Release
            CACHE STRING "Build type of the Hunter packages")
    endif()

    include(defaults/HunterCacheServers)

    HunterGate(
        URL "https://github.com/ruslo/hunter/archive/v0.20.35.tar.gz"
        SHA1 "6e3cb4c333b76803a83c56fcbca3b0bfd9f96f27"
    )
endif()

project(ethash)
set(PROJECT_VERSION 0.4.1)

cable_set_build_type(DEFAULT Release CONFIGURATION_TYPES Release RelWithDebInfo Debug)

cable_configure_compiler(NO_STACK_PROTECTION)
if(CABLE_COMPILER_GNULIKE)
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Og")
    set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_DEBUG} -Og")

    option(ETHASH_NATIVE "Build for native CPU" OFF)
    if(ETHASH_NATIVE)
        add_compile_options(-march=native)
    elseif(NOT CMAKE_CROSSCOMPILING)
        # Tune for currently most common CPUs (flag not supported in cross compilation).
        add_compile_options(-mtune=generic)
    endif()
elseif(MSVC AND CMAKE_SIZEOF_VOID_P EQUAL 4)
    # For Win32 builds allow allocating more than 2 GB of memory.
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} /LARGEADDRESSAWARE")
endif()

option(ETHASH_INSTALL_CMAKE_CONFIG "Install CMake configuration scripts for find_package(CONFIG)" ON)

option(ETHASH_FUZZING "Build with fuzzer instrumentation" OFF)
if(ETHASH_FUZZING)
    set(CMAKE_EXE_LINKER_FLAGS "-fsanitize=fuzzer-no-link ${CMAKE_EXE_LINKER_FLAGS}")
    add_compile_options(-fno-omit-frame-pointer -fsanitize=fuzzer,undefined,integer -fno-sanitize-recover=all)
endif()

add_subdirectory(lib/ethash)


    option(ETHASH_BUILD_TESTS "Build unit tests" ON)
    if(ETHASH_BUILD_TESTS)
        add_subdirectory(test)
    endif()
