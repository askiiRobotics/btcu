cmake_minimum_required(VERSION 3.10)

if(NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        set(CMAKE_TOOLCHAIN_FILE ./cmake/platforms/OSX.cmake)
    endif()
endif()

set(ETH_CMAKE_DIR "${CMAKE_CURRENT_LIST_DIR}/cmake" CACHE PATH "The path to the cmake directory")
list(APPEND CMAKE_MODULE_PATH ${ETH_CMAKE_DIR})

# remove NDEBUG flag from Ethereum
string(REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}")
string(REPLACE "-DNDEBUG" "" CMAKE_C_FLAGS "${CMAKE_C_FLAGS}")

string(REPLACE "-DNDEBUG" "" CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE}")
string(REPLACE "-DNDEBUG" "" CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE}")
    

project(BTCU)
set(PACKAGE_NAME "BTCU")

# TODO: implement all conditions:

# ENABLE_LEASING_MANAGER --disable-leasing-manager   --  ENABLE_LEASING_MANAGER, configure flag, no cmake
# ENABLE_WALLET --disable-wallet  --  ENABLE_WALLET, configure flag, no cmake
# ENABLE_TESTS --disable-tests 
# ENABLE_QT bitcoin_enable_qt --with-gui  --  ENABLE_GUI, configure flag, no cmake
# ENABLE_QT_TESTS --disable-gui-tests 
# ENABLE_BENCH --disable-bench 
# USE_QTCHARTS --with-qtcharts
# USE_LCOV --enable-lcov 
# GLIBC_BACK_COMPAT --enable-glibc-back-compat  --  ENABLE_GLIBC_BACK_COMPAT, configure flag, no cmake
# HARDEN --disable-hardening  --  DISABLE_HARDENING, configure flag, no cmake
# USE_ASM --enable-asm 
# BUILD_BITCOIND --with-daemon 
# BUILD_BITCOIN_UTILS --with-utils  --  BUILD_UTILS, configure flag, no cmake
# BUILD_BITCOIN_LIBS --with-libs  --  BUILD_LIBS, configure flag, no cmake
# ENABLE_ZMQ --disable-zmq  --  ENABLE_ZMQ, configure flag, no cmake
# USE_UPNP --with-miniupnpc  --  WITH_MINIUNPC, configure flag, no cmake
# use_upnp_default --enable-upnp-default  --  START_WITH_UPNP, configure flag, no cmake
# EXTENDED_FUNCTIONAL_TESTS --enable-extended-functional-tests
# use_reduce_exports --enable-reduce-exports  --  ENABLE_REDUCE_EXPORTS, configure flag, no cmake
# use_ccache --disable-ccache
# use_lcov_branch --enable-lcov-branch-coverage
# system_univalue --with-system-univalue
# USE_NUM_GMP USE_NUM_OPENSSL --with-zerocoin-bignum
# PROTOC --with-protoc-bindir
# ENABLE_MAN --disable-man
# enable_debug --enable-debug
# SANITIZER_CXXFLAGS --with-sanitizers
# enable_gprof --enable-gprof  --  ENABLE_GPROF, configure flag, no cmake
# enable_werror --enable-werror

option(ENABLE_LEASING_MANAGER "Disable leasing manager" OFF)
option(ENABLE_GUI "Build btcu-qt" ON)
option(ENABLE_ZMQ "Activate the ZMQ notifications" ON)
option(ENABLE_WALLET "Activate the wallet functionality" ON)
option(BUILD_UTILS "Build btcu-cli and btcu-tx" ON)
option(BUILD_LIBS "Build the btcuconsensus shared library" ON)
option(DISABLE_HARDENING "Do not attempt to harden the resulting executables" OFF)
option(ENABLE_REDUCE_EXPORTS "Attempt to reduce exported symbols in the resulting" OFF)
option(ENABLE_GLIBC_BACK_COMPAT "Enable backwards compatibility with glibc" OFF)
option(WITH_MINIUNPC "Enable UPnP support" ON)
option(START_WITH_UPNP "If UPNP is enabled, turn it on at startup" OFF)
option(ENABLE_GPROF "Use gprof profiling compiler flags " OFF)

set(Boost_USE_STATIC_LIBS ON)
set(Boost_USE_MULTITHREADED ON)

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    message(STATUS "Compiling on macOS")
    set(ENV{target} "Mac")

    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/boost)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/curl)

    set( Boost_NO_BOOST_CMAKE ON )
    set( Boost_USE_STATIC_LIBS OFF )
    set( Boost_NO_SYSTEM_PATHS ON )
    set( Boost_USE_DEBUG_RUNTIME OFF )
    set( Boost_INCLUDE_DIR "/usr/local/opt/boost/include" )
    set( BOOST_LIBRARYDIR "/usr/local/opt/boost/lib" )
    set( BOOST_ROOT "/usr/local/opt/boost" )

    add_definitions(-DBOOST_LOG_DYN_LINK=1)
    add_definitions(-DBOOST_NO_SCOPED_ENUMS=1)
    add_definitions(-DBOOST_NO_CXX11_SCOPED_ENUMS=1)

    message(STATUS Boost_INCLUDE_DIR:)
    message (STATUS ${Boost_INCLUDE_DIR})
endif()

find_package(Boost 1.71.0 EXACT COMPONENTS program_options filesystem system thread context fiber chrono log log_setup REQUIRED)
include_directories(${Boost_INCLUDE_DIRS})

add_definitions(-DETH_FATDB=1)

message(STATUS Boost_LIBRARIES:)
message (STATUS ${Boost_LIBRARIES})

set(BDB_VER "18.1.32")
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/scripts")
include(BrewHelper)

set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/contrib/cmake")
set(CMAKE_CXX_STANDARD 11)
include(${CMAKE_ROOT}/Modules/ExternalProject.cmake)


if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    message(FATAL_ERROR "Native Windows CMake is not supported yet, use WSL instead")
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")    
    find_package(PkgConfig REQUIRED) 

    list(APPEND CMAKE_PREFIX_PATH ./src/jsoncpp)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/qt5)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/berkeley-db)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/rocksdb)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/libjson-rpc-cpp)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/google-benchmark)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/snappy)
    list(APPEND CMAKE_PREFIX_PATH /usr/local/opt/libevent)
    list(APPEND CMAKE_PREFIX_PATH ./src/libscrypt)
    list(APPEND CMAKE_PREFIX_PATH ./src/cryptopp)
    list(APPEND CMAKE_PREFIX_PATH ./src/cpp-ethereum/ethash)

    set(BerkeleyDB_ROOT_DIR "/usr/local/opt/berkeley-db")

    set( CURL_INCLUDE_DIR "/usr/local/opt/curl/include" )
    set( CURL_LIBRARY "/usr/local/opt/curl/lib" )

    set( MHD_INCLUDE_DIR "/usr/local/opt/libmicrohttpd/include" )
    set( MHD_LIBRARY "/usr/local/opt/libmicrohttpd/lib" )

    set( BerkeleyDB_INCLUDE_DIRS "/usr/local/opt/berkeley-db/include" )
    set( BerkeleyDB_LIBRARY "/usr/local/opt/berkeley-db/lib" )

	find_brew_prefix(OPENSSL_ROOT_DIR openssl)

    set( LibEvent_INCLUDE_DIR "/usr/local/opt/libevent/include" )
    set( LibEvent_LIBRARY "/usr/local/opt/libevent/lib" )

    set( GMP_INCLUDE_DIR "/usr/local/opt/gmp/include" )
    set( GMP_LIBRARY "/usr/local/opt/gmp/lib" )

    set( ZMQ_INCLUDE_DIR "/usr/local/opt/zmq/include" )
    set( ZMQ_LIBRARY "/usr/local/opt/zmq/lib" )

    set( Qrcode_INCLUDE_DIR "/usr/local/opt/qrencode/include" )
    set( Qrcode_LIBRARY "/usr/local/opt/qrencode/lib" )
    
    set (CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG 1)
    
elseif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(ENV{target} "Linux")
    file(READ "/proc/version" _SYS_VERSION)
    string(REGEX MATCH "Microsoft" _SYSTEM_VERSION_PARSED "${_SYS_VERSION}")
    if(${_SYSTEM_VERSION_PARSED} MATCHES "Microsoft")
        message(STATUS "Compiling on WSL")
        set(ENV{DISPLAY} ":0")
        set(ENV{LIBGL_ALWAYS_INDIRECT} 1)
        set(CMAKE_RUNTIME_OUTPUT_DIRECTORY /home/$ENV{USER}/btcu-run)
        message(WARNING "WSL Runtime support requires VcXsrv to be installed and running")
    else()
        message(STATUS "Compiling on Linux")
    endif()
    list(APPEND CMAKE_PREFIX_PATH /usr/lib/x86_64-linux-gnu/cmake/Qt5)
    set(Qt5core_DIR "/usr/lib/x86_64-linux-gnu/cmake/Qt5/QtCore")
    find_path(ENDIAN_INCLUDES endian.h)
    if(ENDIAN_INCLUDES)
        message(STATUS "Found endian.h: ${ENDIAN_INCLUDES}")
    endif()
    #add_definitions("-D__BYTE_ORDER -D__LITTLE_ENDIAN -D__GLIBC__ -DHAVE_DECL_BSWAP_16=0 -DHAVE_DECL_BSWAP_32=0 -DHAVE_DECL_BSWAP_64=0")
endif()

if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    find_package(libjson-rpc-cpp CONFIG REQUIRED)

    find_package(Snappy CONFIG REQUIRED)

    find_library(ROCKSDB_LIBRARY rocksdb)

    add_subdirectory(src/libscrypt)

    add_subdirectory(src/cryptopp)

    add_subdirectory(src/jsoncpp/jsoncpp)

    add_subdirectory(src/cpp-ethereum/ethash)
else()
    hunter_add_package(jsoncpp)
    find_package(jsoncpp CONFIG REQUIRED)

    hunter_add_package(cryptopp)
    find_package(cryptopp CONFIG REQUIRED)

    hunter_add_package(libjson-rpc-cpp)
    find_package(libjson-rpc-cpp CONFIG REQUIRED)

    hunter_add_package(libscrypt)
    find_package(libscrypt CONFIG REQUIRED)

    hunter_add_package(ethash)
    find_package(ethash CONFIG REQUIRED)

    hunter_add_package(Snappy)
    find_package(Snappy CONFIG REQUIRED)

    find_library(ROCKSDB_LIBRARY rocksdb)
endif()

# Find Dependencies
find_package(BerkeleyDB REQUIRED)
if(BerkeleyDB_FOUND)
    if(NOT ${BerkeleyDB_VERSION} MATCHES "${BDB_VER}")
        message(WARNING "BerkeleyDB version other than ${BDB_VER} found!")
        set(BDB_CONFIGURE_FLAGS "--with-incompatible-bdb")
    endif()
endif()

find_package(OpenSSL REQUIRED)
if(OPENSSL_FOUND)
    message(STATUS "Found OpenSSL (${OPENSSL_VERSION}): ${OPENSSL_LIBRARIES}")

    message(STATUS OPENSSL_INCLUDE_DIR:)
    message (STATUS ${OPENSSL_INCLUDE_DIR})

    if(OPENSSL_VERSION VERSION_GREATER_EQUAL 1.1)
        message(STATUS "Found unsupported OpenSSL version!")
        set(SSL_CONFIGURE_FLAGS "--with-unsupported-ssl")
    endif()

	set(CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
	set(CMAKE_REQUIRED_LIBRARIES ${OPENSSL_LIBRARIES})

    set(ENV{CPPFLAGS} "-I${OPENSSL_ROOT_DIR}/include -DOBJC_OLD_DISPATCH_PROTOTYPES=0")
    set(ENV{LDFLAGS} "-L${OPENSSL_ROOT_DIR}/lib")

    set(ENV{OPENSSL_ROOT_DIR} "${OPENSSL_ROOT_DIR}")
    set(ENV{OPENSSL_LIB_DIR} "${OPENSSL_ROOT_DIR}/lib")
    set(ENV{OPENSSL_INCLUDE_DIR} "${OPENSSL_ROOT_DIR}/include")

    include_directories(${OPENSSL_INCLUDE_DIR})
    link_directories(${OPENSSL_LIBRARIES})
endif()

find_package(GMP)
if(GMP_FOUND)
    message(STATUS "Found GMP (${GMP_VERSION}): ${GMP_LIBRARIES}")

    message(STATUS GMP_INCLUDE_DIR:)
    message (STATUS ${GMP_INCLUDE_DIR})
else()
    message(WARNING "GMP not found, falling back to OpenSSL for bignum!")
    set(BIGNUM_CONFIGURE_FLAGS "--with-zerocoin-bignum=openssl")
endif()


# run autogen.sh if missing header files from configure on Linux/Mac
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/configure")
else()
    message (STATUS "Need to generate configure. Running: ${CMAKE_CURRENT_SOURCE_DIR}/autogen.sh")

    execute_process(
        COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/autogen.sh
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    )
endif()

# collect config flags
set(PROJECT_CONFIGURE_FLAGS "")
if(ENABLE_GUI)
    message(STATUS "Enabled option: Build btcu-qt")
# default auto
    set(PROJECT_CONFIGURE_FLAGS "--with-gui=auto")
else()
    message(STATUS "Disabled option: Build btcu-qt")
    set(PROJECT_CONFIGURE_FLAGS "--without-gui")
endif()
if(ENABLE_LEASING_MANAGER)
    message(STATUS "Disabled option: Leasing manager")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-leasing-manager")
else()
    message(STATUS "Enabled option: Leasing manager")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-leasing-manager")
endif()
if(ENABLE_ZMQ)
    message(STATUS "Enabled option: Activate the ZMQ notifications")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-zmq")
else()
    message(STATUS "Disabled option: Activate the ZMQ notifications")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-zmq")
endif()
if(ENABLE_WALLET)
    message(STATUS "Enabled option: Activate the wallet functionality")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-wallet")
else()
    message(STATUS "Disabled option: Activate the wallet functionality")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-wallet")
endif()
if(BUILD_UTILS)
    message(STATUS "Enabled option: Build btcu-cli and btcu-tx")
# default yes
#     set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --with-utils")
else()
    message(STATUS "Disabled option: Build btcu-cli and btcu-tx")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --without-utils")
endif()
if(BUILD_LIBS)
    message(STATUS "Enabled option: Build the btcuconsensus shared library")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --with-libs")
else()
    message(STATUS "Disabled option: Build the btcuconsensus shared library")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --without-libs")
endif()
if(DISABLE_HARDENING)
    message(STATUS "Disabled option: Harden the executables")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-hardening")
else()
    message(STATUS "Enabled option: Harden the executables")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-hardening")
endif()
if(ENABLE_REDUCE_EXPORTS)
    message(STATUS "Enabled option: Attempt to reduce exported symbols in the resulting")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-reduce-exports")
else()
    message(STATUS "Disabled option: Attempt to reduce exported symbols in the resulting")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-reduce-exports")
endif()
if(ENABLE_GLIBC_BACK_COMPAT)
    message(STATUS "Enabled option: Backwards compatibility with glibc")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-glibc-back-compat")
else()
    message(STATUS "Disabled option: Backwards compatibility with glibc")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-glibc-back-compat")
endif()
if(WITH_MINIUNPC)
    message(STATUS "Enabled option: UPnP support")
# default yes
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --with-miniupnpc")
else()
    message(STATUS "Disabled option: UPnP support")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --without-miniupnpc")
endif()
if(START_WITH_UPNP)
    message(STATUS "Enabled option: If UPNP is enabled, turn it on at startup")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-upnp-default")
else()
    message(STATUS "Disabled option: If UPNP is enabled, turn it on at startup")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-upnp-default")
endif()
if(ENABLE_GPROF)
    message(STATUS "Enabled option: Use gprof profiling compiler flags")
    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --enable-gprof")
else()
    message(STATUS "Disabled option: Use gprof profiling compiler flags")
# default no
#    set(PROJECT_CONFIGURE_FLAGS "${PROJECT_CONFIGURE_FLAGS} --disable-gprof")
endif()

# run configure in order to update or create btcu-config.h

find_program(GCC_COMPILER_FOR_AUTOCONF g++)
find_program(CC_COMPILER_FOR_AUTOCONF cc)
    
message (STATUS "Updating btcu-config.h. Running: ${CMAKE_CURRENT_SOURCE_DIR}/configure ${PROJECT_CONFIGURE_FLAGS} ${CONFIGSITE} ${BDB_CONFIGURE_FLAGS} ${BIGNUM_CONFIGURE_FLAGS} ${SSL_CONFIGURE_FLAGS} CC=${CC_COMPILER_FOR_AUTOCONF} CXX=${GCC_COMPILER_FOR_AUTOCONF}")

execute_process(
    COMMAND ${CMAKE_CURRENT_SOURCE_DIR}/configure ${PROJECT_CONFIGURE_FLAGS} ${CONFIGSITE} ${BDB_CONFIGURE_FLAGS} ${BIGNUM_CONFIGURE_FLAGS} ${SSL_CONFIGURE_FLAGS} CC=${CC_COMPILER_FOR_AUTOCONF} CXX=${GCC_COMPILER_FOR_AUTOCONF} 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_definitions(-DHAVE_CONFIG_H)

find_package(LibEvent REQUIRED)

find_package(ZMQ)
if(ZMQ_FOUND)
    message(STATUS "Found ZMQ (${ZMQ_VERSION}): ${ZMQ_LIBRARIES}")

    message(STATUS ZMQ_INCLUDE_DIRS:)
    message (STATUS ${ZMQ_INCLUDE_DIRS})
else()
    message(WARNING "ZMQ not found!")
endif()
find_package(miniupnp)

add_subdirectory(src/libff)

# Find the python interpreter. This is required for several targets.
find_package(Python 3.5 COMPONENTS Interpreter REQUIRED)

ExternalProject_Add (
        libunivalue
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/univalue
        CONFIGURE_COMMAND ""
        BUILD_COMMAND $(MAKE)
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ""
        )

ExternalProject_Add (
        libsecp256k1
        SOURCE_DIR ${CMAKE_SOURCE_DIR}/src/secp256k1
        CONFIGURE_COMMAND ""
        BUILD_COMMAND $(MAKE)
        BUILD_IN_SOURCE 1
        INSTALL_COMMAND ""
        )

link_directories(
        ${CMAKE_SOURCE_DIR}/src/univalue/.libs
        ${CMAKE_SOURCE_DIR}/src/secp256k1/.libs
        )
link_directories(${CMAKE_BINARY_DIR})

set(libleveldb_a_headers
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/atomic_pointer.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_example.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_posix.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/win/stdint.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_win.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/thread_annotations.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/db.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/options.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/comparator.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/filter_policy.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/slice.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/table_builder.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/env.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/c.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/iterator.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/cache.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/dumpfile.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/table.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/write_batch.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include/leveldb/status.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/log_format.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/memtable.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/version_set.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/write_batch_internal.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/filename.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/version_edit.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/dbformat.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/builder.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/log_writer.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/db_iter.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/skiplist.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/db_impl.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/table_cache.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/snapshot.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/log_reader.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/filter_block.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/block_builder.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/block.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/two_level_iterator.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/merger.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/format.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/iterator_wrapper.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/crc32c.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/env_posix_test_helper.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/arena.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/random.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/posix_logger.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/hash.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/histogram.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/coding.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/testutil.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/mutexlock.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/logging.h
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/testharness.h
        )

set(libleveldb_a_sources
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/builder.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/c.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/dbformat.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/db_impl.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/db_iter.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/dumpfile.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/filename.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/log_reader.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/log_writer.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/memtable.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/repair.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/table_cache.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/version_edit.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/version_set.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/db/write_batch.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/block_builder.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/block.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/filter_block.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/format.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/iterator.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/merger.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/table_builder.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/table.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/table/two_level_iterator.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/arena.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/bloom.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/cache.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/coding.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/comparator.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/crc32c.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/env.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/env_posix.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/filter_policy.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/hash.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/histogram.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/logging.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/options.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/status.cc
        )

set(libleveldb_cpp_flags)
if($ENV{target} MATCHES "Windows")
        set(libleveldb_cpp_flags -DOS_WINDOWS -DLEVELDB_PLATFORM_WINDOWS -DWINVER=0x0500 -D__USE_MINGW_ANSI_STDIO=1)
        set(libleveldb_a_sources ${libleveldb_a_sources} ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/util/env_win.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_win.cc)
else()
    if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
        set(libleveldb_cpp_flags -DOS_MACOSX -DLEVELDB_PLATFORM_POSIX)
    else()
        set(libleveldb_cpp_flags -DOS_LINUX -DLEVELDB_PLATFORM_POSIX)
    endif()
    set(libleveldb_a_sources ${libleveldb_a_sources} ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_posix.cc)
endif()

add_library(leveldb ${libleveldb_a_headers} ${libleveldb_a_sources})
target_compile_definitions(leveldb PUBLIC ${libleveldb_cpp_flags} -DLEVELDB_ATOMIC_PRESENT -D__STDC_LIMIT_MACROS)
target_include_directories(leveldb PUBLIC ${ENDIAN_INCLUDES}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv
        )

set(libmemenv_a_sources
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv/memenv.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv/memenv.h
        )
add_library(memenv STATIC ${libmemenv_a_sources})
target_compile_definitions(memenv PUBLIC ${libleveldb_cpp_flags})
target_include_directories(memenv PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv
        )

set(libleveldb_sse42_a_sources ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/port/port_posix_sse.cc)
add_library(leveldb_sse42 ${libleveldb_sse42_a_sources})
target_include_directories(leveldb_sse42 PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv
        )

target_link_libraries(leveldb leveldb_sse42)

file(GLOB HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.h)
file(GLOB CRYPTO_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/crypto/*.h)
file(GLOB PRIMITIVE_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/primitives/*.h)
file(GLOB ZMQ_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/zmq/*.h)
file(GLOB SCRIPT_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/script/*.h)
file(GLOB RPC_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/rpc/*.h)
file(GLOB COMPAT_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/src/compat/*.h)

source_group("BitcoinHeaders" FILES
        ${HEADERS}
        ${CRYPTO_HEADERS}
        ${PRIMITIVE_HEADERS}
        ${ZMQ_HEADERS}
        ${SCRIPT_HEADERS}
        ${RPC_HEADERS}
        ${COMPAT_HEADERS}
        ./src/support/cleanse.h
        )

set(SERVER_SOURCES
        ./src/addrman.cpp
        ./src/alert.cpp
        ./src/bloom.cpp
        ./src/blocksignature.cpp
        ./src/chain.cpp
        ./src/checkpoints.cpp
        ./src/httprpc.cpp
        ./src/httpserver.cpp
        ./src/init.cpp
        ./src/leveldbwrapper.cpp
        ./src/main.cpp
        ./src/contract.cpp
        ./src/merkleblock.cpp
        ./src/miner.cpp
        ./src/net.cpp
        ./src/noui.cpp
        ./src/pow.cpp
        ./src/rest.cpp
        ./src/rpc/blockchain.cpp
        ./src/rpc/masternode.cpp
        ./src/rpc/budget.cpp
        ./src/rpc/mining.cpp
        ./src/rpc/misc.cpp
        ./src/rpc/net.cpp
        ./src/rpc/rawtransaction.cpp
        ./src/rpc/server.cpp
        ./src/rpc/validators.cpp
        ./src/masternode-validators.cpp
        ./src/script/sigcache.cpp
        ./src/sporkdb.cpp
        ./src/timedata.cpp
        ./src/torcontrol.cpp
        ./src/txdb.cpp
        ./src/txmempool.cpp
        ./src/validationinterface.cpp
        ./src/zbtcuchain.cpp
        ./src/cpp-ethereum/ethash/lib/ethash/keccak.c
        ./src/cpp-ethereum/ethash/lib/ethash/ethash.cpp
        ./src/cpp-ethereum/ethash/lib/ethash/keccakf1600.c
        ./src/cpp-ethereum/ethash/lib/ethash/primes.c
        ./src/cpp-ethereum/libdevcore/CommonData.cpp
        ./src/qtum/qtumDGP.cpp
        ./src/qtum/qtumstate.cpp
        #./src/cpp-ethereum/libethereum/State.cpp

        ./src/cpp-ethereum/aleth/buildinfo.c
        ./src/cpp-ethereum/evmc/lib/instructions/instruction_metrics.c
        ./src/cpp-ethereum/evmc/lib/instructions/instruction_names.c
        ./src/cpp-ethereum/libdevcore/Address.cpp
        ./src/cpp-ethereum/libdevcore/Base64.cpp
        ./src/cpp-ethereum/libdevcore/Common.cpp
        ./src/cpp-ethereum/libdevcore/CommonData.cpp
        ./src/cpp-ethereum/libdevcore/CommonIO.cpp
        ./src/cpp-ethereum/libdevcore/CommonJS.cpp
        ./src/cpp-ethereum/libdevcore/FileSystem.cpp
        ./src/cpp-ethereum/libdevcore/FixedHash.cpp
        ./src/cpp-ethereum/libdevcore/Guards.cpp
        ./src/cpp-ethereum/libdevcrypto/Hash.cpp
        ./src/cpp-ethereum/libdevcore/Log.cpp
        ./src/cpp-ethereum/libdevcore/LevelDB.cpp
        ./src/cpp-ethereum/libdevcore/MemoryDB.cpp
        ./src/cpp-ethereum/libdevcore/OverlayDB.cpp
        ./src/cpp-ethereum/libdevcore/StateCacheDB.cpp
        ./src/cpp-ethereum/libdevcore/RLP.cpp
        ./src/cpp-ethereum/libdevcore/SHA3.cpp
        ./src/cpp-ethereum/libdevcore/TransientDirectory.cpp
        ./src/cpp-ethereum/libdevcore/TrieCommon.cpp
        ./src/cpp-ethereum/libdevcore/Worker.cpp
        ./src/cpp-ethereum/libdevcore/DBFactory.cpp
        ./src/cpp-ethereum/libdevcore/JsonUtils.cpp
        ./src/cpp-ethereum/libevm/EVMC.cpp
        ./src/cpp-ethereum/libevm/ExtVMFace.cpp
        ./src/cpp-ethereum/libaleth-interpreter/VM.cpp
        ./src/cpp-ethereum/libaleth-interpreter/VMOpt.cpp
        ./src/cpp-ethereum/libaleth-interpreter/VMCalls.cpp
        ./src/cpp-ethereum/libevm/VMFactory.cpp
        ./src/cpp-ethereum/libevm/Instruction.cpp
        ./src/cpp-ethereum/libevm/LegacyVM.cpp
        ./src/cpp-ethereum/libevm/LegacyVMCalls.cpp
        ./src/cpp-ethereum/libevm/LegacyVMOpt.cpp
        ./src/cpp-ethereum/libethereum/ImportPerformanceLogger.cpp
        ./src/cpp-ethereum/libethereum/Account.cpp
        ./src/cpp-ethereum/libethereum/GasPricer.cpp
        ./src/cpp-ethereum/libethereum/State.cpp
        ./src/cpp-ethereum/libethcore/ABI.cpp
        ./src/cpp-ethereum/libethcore/ChainOperationParams.cpp
        ./src/cpp-ethereum/libethcore/Common.cpp
        ./src/cpp-ethereum/libethcore/Precompiled.cpp
        ./src/cpp-ethereum/libethcore/TransactionBase.cpp
        ./src/cpp-ethereum/libdevcrypto/Common.cpp
        ./src/cpp-ethereum/libdevcrypto/CryptoPP.cpp
        ./src/cpp-ethereum/libdevcrypto/AES.cpp
        ./src/cpp-ethereum/libdevcrypto/LibSnark.cpp
        ./src/cpp-ethereum/libethereum/ChainParams.cpp
        ./src/cpp-ethereum/libethereum/Transaction.cpp
        ./src/cpp-ethereum/libethereum/Executive.cpp
        ./src/cpp-ethereum/libethereum/ExtVM.cpp
        ./src/cpp-ethereum/libethereum/Block.cpp
        ./src/cpp-ethereum/libethereum/BlockChain.cpp
        ./src/cpp-ethereum/libethereum/BlockDetails.cpp
        ./src/cpp-ethereum/libethereum/TransactionQueue.cpp
        ./src/cpp-ethereum/libethereum/BlockQueue.cpp
        ./src/cpp-ethereum/libethcore/BlockHeader.cpp
        ./src/cpp-ethereum/libdevcore/RLP.cpp
        ./src/cpp-ethereum/libethereum/TransactionReceipt.cpp
        ./src/cpp-ethereum/libethcore/SealEngine.cpp
        ./src/cpp-ethereum/libdevcore/TrieHash.cpp
        ./src/cpp-ethereum/libethereum/GenesisInfo.cpp

        ./src/cpp-ethereum/libethereum/ValidationSchemes.cpp
        ./src/cpp-ethereum/libethcore/LogEntry.cpp
        ./src/cpp-ethereum/ethash/lib/ethash/ethash.cpp
        ./src/cpp-ethereum/ethash/lib/ethash/keccak.c
        ./src/cpp-ethereum/ethash/lib/ethash/keccakf800.c
        ./src/cpp-ethereum/ethash/lib/ethash/keccakf1600.c
        ./src/cpp-ethereum/ethash/lib/ethash/managed.cpp
        ./src/cpp-ethereum/ethash/lib/ethash/primes.c
        ./src/cpp-ethereum/ethash/lib/ethash/progpow.cpp
        ./src/cpp-ethereum/evmc/lib/loader/loader.c
        ./src/cpp-ethereum/libdevcore/RocksDB.cpp
        ./src/validation.cpp
        ./src/consensus/consensus.cpp
        ./src/zbtcuchain.cpp
        )


add_library(SERVER_A STATIC ${BitcoinHeaders} ${SERVER_SOURCES})
if(MINIUPNP_FOUND)
    target_include_directories(SERVER_A PUBLIC
        ${MINIUPNP_INCLUDE_DIR}
        )
    target_link_libraries(SERVER_A 
        ${MINIUPNP_LIBRARY}
        )
endif()
target_include_directories(SERVER_A
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/univalue/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv
        ${ZMQ_INCLUDE_DIRS}
        ${LibEvent_INCLUDE_DIR}
        ${BerkeleyDB_INCLUDE_DIRS}
        ${OPENSSL_INCLUDE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/ethash/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/evmc/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/qtum
        ${CMAKE_CURRENT_SOURCE_DIR}/src/secp256k1/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/libdevcore
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/utils
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/utils/libscrypt
        ${CMAKE_CURRENT_SOURCE_DIR}/src/libff/libff
        ${CMAKE_CURRENT_SOURCE_DIR}/src/libff
    )
add_dependencies(SERVER_A libunivalue leveldb libsecp256k1)
target_link_libraries(SERVER_A 
        univalue
        UTIL_A
        BITCOIN_CRYPTO_A
        COMMON_A
        ${Boost_LIBRARIES} 
        cryptopp-shared 
        ${LibEvent_LIBRARIES}
        ${BerkeleyDB_Cxx_LIBRARY}
        ${OPENSSL_LIBRARIES}
        ${ZMQ_LIBRARIES}
        jsoncpp_lib
        leveldb
        secp256k1
        ${ROCKSDB_LIBRARY}
        ${CMAKE_DL_LIBS}
        Threads::Threads 
        ff 
        Snappy::snappy
        Threads::Threads
        scrypt
        )

set(WALLET_SOURCES
        ./src/activemasternode.cpp
        ./src/bip38.cpp
        ./src/denomination_functions.cpp
        ./src/obfuscation.cpp
        ./src/obfuscation-relay.cpp
        ./src/wallet/db.cpp
        ./src/addressbook.cpp
        ./src/crypter.cpp
        ./src/swifttx.cpp
        ./src/masternode.cpp
        ./src/masternode-budget.cpp
        ./src/masternode-payments.cpp
        ./src/masternode-sync.cpp
        ./src/masternodeconfig.cpp
        ./src/masternodeman.cpp
        ./src/messagesigner.cpp
        ./src/zbtcu/mintpool.cpp
        ./src/wallet/rpcdump.cpp
        ./src/zbtcu/deterministicmint.cpp
        ./src/zbtcu/zerocoin.cpp
        ./src/wallet/rpcwallet.cpp
        ./src/kernel.cpp
        ./src/wallet/wallet.cpp
        ./src/wallet/wallet_zerocoin.cpp
        ./src/wallet/wallet_ismine.cpp
        ./src/wallet/walletdb.cpp
        ./src/leasing/leasingmanager.cpp
        ./src/leasing/leasing_tx_verify.cpp
        ./src/zbtcu/zbtcuwallet.cpp
        ./src/zbtcu/zbtcutracker.cpp
        ./src/zbtcu/zbtcumodule.cpp
        ./src/zbtcu/zpos.cpp
        ./src/stakeinput.cpp
        )

if(ZMQ_FOUND)
    set(ZMQ_SOURCES
        ./src/zmq/zmqabstractnotifier.cpp
        ./src/zmq/zmqnotificationinterface.cpp
        ./src/zmq/zmqpublishnotifier.cpp
    )
    add_library(ZMQ_A STATIC ${BitcoinHeaders} ${ZMQ_SOURCES})
    target_include_directories(ZMQ_A PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src ${ZMQ_INCLUDE_DIRS} ${OPENSSL_INCLUDE_DIR})
    target_link_libraries(ZMQ_A 
        ${ZMQ_LIBRARIES}
        )
    if(GMP_FOUND)
        target_include_directories(ZMQ_A PUBLIC ${GMP_INCLUDE_DIR})
    endif()
    target_compile_definitions(ZMQ_A PUBLIC "-DZMQ_STATIC")
endif()

add_library(WALLET_A STATIC ${BitcoinHeaders} ${WALLET_SOURCES})
target_include_directories(WALLET_A PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/secp256k1/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/univalue/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/jsoncpp/jsoncpp/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/ethash/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/evmc/include
        ${OPENSSL_INCLUDE_DIR}
        ${BerkeleyDB_INCLUDE_DIRS}
        )
if(GMP_FOUND)
    target_include_directories(WALLET_A PUBLIC ${GMP_INCLUDE_DIR})
endif()
set(BITCOIN_CRYPTO_SOURCES
        ./src/crypto/sha1.cpp
        ./src/crypto/sha256.cpp
        ./src/crypto/sha512.cpp
        ./src/crypto/chacha20.cpp
        ./src/crypto/hmac_sha256.cpp
        ./src/crypto/rfc6979_hmac_sha256.cpp
        ./src/crypto/hmac_sha512.cpp
        ./src/crypto/scrypt.cpp
        ./src/crypto/ripemd160.cpp
        ./src/crypto/aes_helper.c
        ./src/crypto/blake.c
        ./src/crypto/bmw.c
        ./src/crypto/groestl.c
        ./src/crypto/jh.c
        ./src/crypto/keccak.c
        ./src/crypto/skein.c
        )
add_library(BITCOIN_CRYPTO_A ${BITCOIN_CRYPTO_SOURCES})
add_dependencies(BITCOIN_CRYPTO_A libunivalue)
target_link_libraries(BITCOIN_CRYPTO_A
            univalue
            ${Boost_LIBRARIES} 
            ${OPENSSL_LIBRARIES}
            ${LibEvent_LIBRARIES}
            Threads::Threads
        )
target_include_directories(BITCOIN_CRYPTO_A PUBLIC 
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${OPENSSL_INCLUDE_DIR}
    )

set(COMMON_SOURCES
        ./src/allocators.cpp
        ./src/amount.cpp
        ./src/base58.cpp
        ./src/bech32.cpp
        ./src/bip38.cpp
        ./src/chainparams.cpp
        ./src/coins.cpp
        ./src/compressor.cpp
        ./src/consensus/merkle.cpp
        ./src/consensus/tx_verify.cpp
        ./src/consensus/validator_tx_verify.cpp
        ./src/primitives/block.cpp
        ./src/zbtcu/deterministicmint.cpp
        ./src/primitives/transaction.cpp
        ./src/zbtcu/zerocoin.cpp
        ./src/core_read.cpp
        ./src/core_write.cpp
        ./src/hash.cpp
        ./src/invalid.cpp
        ./src/key.cpp
        ./src/btcu_address.cpp
        ./src/keystore.cpp
        ./src/netbase.cpp
        ./src/protocol.cpp
        ./src/pubkey.cpp
        ./src/scheduler.cpp
        ./src/script/interpreter.cpp
        ./src/script/script.cpp
        ./src/script/sign.cpp
        ./src/script/standard.cpp
        ./src/script/script_error.cpp
        ./src/spork.cpp
        ./src/sporkdb.cpp
        ./src/validators_state.cpp
        ./src/validators_voting.cpp

        ./src/cpp-ethereum/libethashseal/Ethash.cpp
        ./src/cpp-ethereum/libethashseal/EthashCPUMiner.cpp
        ./src/cpp-ethereum/libethashseal/EthashProofOfWork.cpp

        ./src/cpp-ethereum/libethashseal/GenesisInfo.cpp
        )

add_library(COMMON_A STATIC ${BitcoinHeaders} ${COMMON_SOURCES})
target_include_directories(COMMON_A 
    PUBLIC 
        ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/secp256k1/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/univalue/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/jsoncpp/jsoncpp/include
        ${OPENSSL_INCLUDE_DIR}
        ${BerkeleyDB_INCLUDE_DIRS}
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/ethash/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/evmc/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/qtum
        )
target_link_libraries(COMMON_A 
            jsoncpp_lib
            BITCOIN_CRYPTO_A
            ${Boost_LIBRARIES} 
            ${OPENSSL_LIBRARIES}
            ${LibEvent_LIBRARIES}
            UTIL_A
            SERVER_A
        )
if(GMP_FOUND)
    target_link_libraries(COMMON_A ${GMP_LIBRARIES})
    target_include_directories(COMMON_A PUBLIC ${GMP_INCLUDE_DIR})
endif()
set(ZEROCOIN_SOURCES
        ./src/libzerocoin/bignum.cpp
        ./src/libzerocoin/Accumulator.cpp
        ./src/libzerocoin/Coin.cpp
        ./src/libzerocoin/CoinRandomnessSchnorrSignature.cpp
        ./src/libzerocoin/Denominations.cpp
        ./src/libzerocoin/CoinSpend.cpp
        ./src/libzerocoin/ParamGeneration.cpp
        ./src/libzerocoin/Params.cpp
        )

add_library(ZEROCOIN_A ${ZEROCOIN_SOURCES})
add_dependencies(ZEROCOIN_A libsecp256k1)
target_include_directories(ZEROCOIN_A PUBLIC
            ${CMAKE_CURRENT_SOURCE_DIR}/src
            ${OPENSSL_INCLUDE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}/src/secp256k1/include
        )
target_link_libraries(ZEROCOIN_A
            UTIL_A
            BITCOIN_CRYPTO_A
            ${Boost_LIBRARIES} 
            ${OPENSSL_LIBRARIES}
            ${LibEvent_LIBRARIES}
            jsoncpp_lib
            COMMON_A
            secp256k1
        )
if(GMP_FOUND)
    target_link_libraries(ZEROCOIN_A ${GMP_LIBRARIES})
    target_include_directories(ZEROCOIN_A PUBLIC ${GMP_INCLUDE_DIR})
endif()

set(UTIL_SOURCES
        ./src/allocators.cpp
        ./src/compat/strnlen.cpp
        ./src/compat/glibc_sanity.cpp
        ./src/compat/glibcxx_sanity.cpp
        ./src/chainparamsbase.cpp
        ./src/clientversion.cpp
        ./src/random.cpp
        ./src/rpc/protocol.cpp
        ./src/sync.cpp
        ./src/uint256.cpp
        ./src/util.cpp
        ./src/utilstrencodings.cpp
        ./src/utilmoneystr.cpp
        ./src/utiltime.cpp
        ./src/support/cleanse.cpp
        ./src/util/string.cpp
        )
add_library(UTIL_A 
            ${BitcoinHeaders} 
            ${UTIL_SOURCES}
        )
target_include_directories(UTIL_A PUBLIC 
            ${CMAKE_CURRENT_SOURCE_DIR}/src
            ${CMAKE_CURRENT_SOURCE_DIR}/src/univalue/include
            ${OPENSSL_INCLUDE_DIR}
            ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/
        )
add_dependencies(UTIL_A libunivalue)
target_link_libraries(UTIL_A
            univalue
            BITCOIN_CRYPTO_A
            ${Boost_LIBRARIES} 
            ${OPENSSL_LIBRARIES}
            ${LibEvent_LIBRARIES}
            Threads::Threads
        )

set(CLI_A_SOURCES ./src/rpc/client.cpp)
add_library(CLI_A ${BitcoinHeaders} ${CLI_A_SOURCES})
target_include_directories(CLI_A 
            PUBLIC 
                ${CMAKE_CURRENT_SOURCE_DIR}/src
                ${CMAKE_CURRENT_SOURCE_DIR}/src/univalue/include
        )
add_dependencies(CLI_A libunivalue)
target_link_libraries(CLI_A
            univalue
            BITCOIN_CRYPTO_A
            ${Boost_LIBRARIES} 
            ${OPENSSL_LIBRARIES}
            ${LibEvent_LIBRARIES}
            Threads::Threads
        )

set(btcu-cli_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcu-cli.cpp)
if($ENV{target} MATCHES "Windows")
    list(APPEND btcu-cli_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcu-cli-res.rc)
endif()
add_executable(btcu-cli ${btcu-cli_SOURCES})
add_dependencies(btcu-cli libunivalue)
target_link_libraries(btcu-cli
        CLI_A
        univalue
        UTIL_A
        BITCOIN_CRYPTO_A
        ${Boost_LIBRARIES} 
        ${OPENSSL_LIBRARIES}
        ${LibEvent_LIBRARIES}
        Threads::Threads
        )
target_include_directories(btcu-cli 
            PUBLIC 
                ${LibEvent_INCLUDE_DIR}
        )
if($ENV{target} MATCHES "Windows")
    target_link_libraries(btcu-cli ${WINDOWS_LDADD})
endif()

set(btcu-tx_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcu-tx.cpp)
if($ENV{target} MATCHES "Windows")
    list(APPEND btcu-tx_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcu-tx-res.rc)
endif()
add_executable(btcu-tx ${btcu-tx_SOURCES})
add_dependencies(btcu-tx libunivalue libsecp256k1)
target_link_libraries(btcu-tx
        univalue
        COMMON_A
        SERVER_A
        ZEROCOIN_A
        UTIL_A
        BITCOIN_CRYPTO_A
        secp256k1
        ${Boost_LIBRARIES} 
        ${OPENSSL_LIBRARIES}
        ${LibEvent_LIBRARIES}
        )
if($ENV{target} MATCHES "Windows")
    target_link_libraries(btcu-tx ${WINDOWS_LDADD})
endif()
if(GMP_FOUND)
    target_link_libraries(btcu-tx ${GMP_LIBRARIES})
endif()

set(btcud_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcud.cpp ${Boost_LOG_LIBRARY} ${Boost_LOG_SETUP_LIBRARY})
if($ENV{target} MATCHES "Windows")
    list(APPEND btcud_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/btcud-res.rc)
endif()
add_executable(btcud ${btcud_SOURCES} ${BitcoinHeaders})
add_dependencies(btcud libunivalue libsecp256k1 leveldb leveldb_sse42 memenv)
target_include_directories(btcud PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/src
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/include
        ${CMAKE_CURRENT_SOURCE_DIR}/src/leveldb/helpers/memenv
        ${btcud_SOURCES}
        ${LibEvent_INCLUDE_DIR})
target_link_libraries(btcud
        Threads::Threads
        SERVER_A
        WALLET_A
        univalue
        COMMON_A
        ZEROCOIN_A
        UTIL_A
        BITCOIN_CRYPTO_A
        leveldb
        leveldb_sse42
        memenv
        secp256k1
        ${BerkeleyDB_Cxx_LIBRARY}
        ${OPENSSL_LIBRARIES}
        ${Boost_LIBRARIES}
        ${LibEvent_LIBRARIES}
        )

if($ENV{target} MATCHES "Windows")
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wstack-protector -fstack-protector-all -fPIE -pipe -O2 -pthread -Wl,--dynamicbase -Wl,--nxcompat -Wl,--high-entropy-va -pie --static")
    target_link_libraries(btcud ${WINDOWS_LDADD})
endif()
if(GMP_FOUND)
    target_link_libraries(btcud ${GMP_LIBRARIES})
    target_include_directories(btcud PUBLIC ${GMP_INCLUDE_DIR})
endif()
if(ZMQ_FOUND)
    target_link_libraries(btcud ZMQ_A ${ZMQ_LIBRARIES})
    target_include_directories(btcud PUBLIC ${ZMQ_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/)
endif()
if(MINIUPNP_FOUND)
    target_compile_definitions(btcud PUBLIC "-DSTATICLIB -DMINIUPNP_STATICLIB")
    target_link_libraries(btcud ${MINIUPNP_LIBRARY})
    target_include_directories(btcud PUBLIC ${MINIUPNP_INCLUDE_DIR})
endif()

add_subdirectory(src/qt)


set(BTCU_TEST_SOURCES
        ./src/test/test_btcu.cpp
        ./src/test/zerocoin_denomination_tests.cpp
        ./src/test/zerocoin_transactions_tests.cpp
        ./src/test/zerocoin_bignum_tests.cpp
        ./src/test/addrman_tests.cpp
        ./src/test/allocator_tests.cpp
        ./src/test/base32_tests.cpp
        ./src/test/base58_tests.cpp
        ./src/test/base64_tests.cpp
        ./src/test/budget_tests.cpp
        ./src/test/checkblock_tests.cpp
        ./src/test/Checkpoints_tests.cpp
        ./src/test/coins_tests.cpp
        ./src/test/compress_tests.cpp
        ./src/test/crypto_tests.cpp
        ./src/test/DoS_tests.cpp
        ./src/test/getarg_tests.cpp
        ./src/test/hash_tests.cpp
        ./src/test/key_tests.cpp
        ./src/test/main_tests.cpp
        ./src/test/mempool_tests.cpp
        ./src/test/merkle_tests.cpp
        ./src/test/mruset_tests.cpp
        ./src/test/multisig_tests.cpp
        ./src/test/netbase_tests.cpp
        ./src/test/pmt_tests.cpp
        ./src/test/random_tests.cpp
        ./src/test/reverselock_tests.cpp
        ./src/test/rpc_tests.cpp
        ./src/test/sanity_tests.cpp
        ./src/test/scheduler_tests.cpp
        ./src/test/script_P2SH_tests.cpp
        ./src/test/script_tests.cpp
        ./src/test/scriptnum_tests.cpp
        ./src/test/serialize_tests.cpp
        ./src/test/sighash_tests.cpp
        ./src/test/sigopcount_tests.cpp
        ./src/test/skiplist_tests.cpp
        ./src/test/timedata_tests.cpp
        ./src/test/torcontrol_tests.cpp
        ./src/test/transaction_tests.cpp
        ./src/test/uint256_tests.cpp
        ./src/test/univalue_tests.cpp
        ./src/test/util_tests.cpp

        # Wallet tests
        ./src/test/accounting_tests.cpp
        ./src/wallet/test/wallet_tests.cpp
        ./src/test/rpc_wallet_tests.cpp
    )

set(BTCU_JSON_TEST_FILES
        ./src/test/data/script_valid.json
        ./src/test/data/base58_keys_valid.json
        ./src/test/data/sig_canonical.json
        ./src/test/data/sig_noncanonical.json
        ./src/test/data/base58_encode_decode.json
        ./src/test/data/base58_keys_invalid.json
        ./src/test/data/script_invalid.json
        ./src/test/data/tx_invalid.json
        ./src/test/data/tx_valid.json
        ./src/test/data/sighash.json
    )

set(BTCU_RAW_TEST_FILES
        ./src/test/data/alertTests.raw
    )

find_program(HEXDUMP hexdump)
find_program(SED sed)

macro(BTCU_HEXDUMP SRC_FILE DST_NAMESPACE DST_LIST)
    get_filename_component(SRC_VAR_NAME ${SRC_FILE} NAME_WE)
    set(SRC_IN ${CMAKE_CURRENT_SOURCE_DIR}/${SRC_FILE})
    set(SRC_OUT ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILE}.h)
    set(SRC_TMP ${CMAKE_CURRENT_BINARY_DIR}/${SRC_FILE}.tmp)
    get_filename_component(SRC_OUT_DIR ${SRC_OUT} DIRECTORY)
    add_custom_command(
        OUTPUT
            ${SRC_OUT}
        COMMAND
            ${CMAKE_COMMAND} -E make_directory ${SRC_OUT_DIR}
        COMMAND
            ${CMAKE_COMMAND} -E echo "namespace ${DST_NAMESPACE}" { > ${SRC_OUT}
        COMMAND
            ${CMAKE_COMMAND} -E echo "static unsigned const char ${SRC_VAR_NAME}[] = {" >> ${SRC_OUT}
        COMMAND
            ${HEXDUMP} -v -e '8/1 \"0x%02x, \"' -e '\"\\n\"' ${SRC_IN} > ${SRC_TMP}
        COMMAND
            ${SED} -e 's/0x\ \ ,//g' ${SRC_TMP} >> ${SRC_OUT}
        COMMAND
            ${CMAKE_COMMAND} -E echo "}\;}\;" >> ${SRC_OUT}
        MAIN_DEPENDENCY
            ${SRC_FILE}
    )
    list(APPEND ${DST_LIST} ${SRC_OUT})
endmacro(BTCU_HEXDUMP)

foreach(BTCU_JSON_FILE ${BTCU_JSON_TEST_FILES})
    BTCU_HEXDUMP(${BTCU_JSON_FILE} json_tests BTCU_HEX_TEST_FILES)
endforeach(BTCU_JSON_FILE)

foreach(BTCU_RAW_FILE ${BTCU_RAW_TEST_FILES})
    BTCU_HEXDUMP(${BTCU_RAW_FILE} alert_tests BTCU_HEX_TEST_FILES)
endforeach(BTCU_RAW_FILE)

list(GET BTCU_HEX_TEST_FILES 0 BTCU_HEX_DEST_FILE)
get_filename_component(BTCU_HEX_DESTDIR ${BTCU_HEX_DEST_FILE} DIRECTORY)
get_filename_component(BTCU_HEX_DESTDIR ${BTCU_HEX_DESTDIR} DIRECTORY)

    add_custom_target(test_btcu_hex ALL DEPENDS ${BTCU_HEX_TEST_FILES})

    add_executable(test_btcu ${BTCU_TEST_SOURCES})
    target_compile_definitions(test_btcu PUBLIC -DBOOST_TEST_DYN_LINK)
    add_dependencies(test_btcu test_btcu_hex libunivalue libsecp256k1 leveldb leveldb_sse42 memenv)
    target_include_directories(test_btcu PUBLIC ${BTCU_HEX_DESTDIR} ./src/test)

    target_link_libraries(test_btcu
            SERVER_A
            WALLET_A
            univalue
            COMMON_A
            ZEROCOIN_A
            UTIL_A
            CLI_A
            BITCOIN_CRYPTO_A
            leveldb
            leveldb_sse42
            memenv
            secp256k1
            ${BerkeleyDB_Cxx_LIBRARY}
            ${OPENSSL_LIBRARIES}
            ${Boost_LIBRARIES}
            ${Boost_UNIT_TEST_FRAMEWORK_LIBRARY}
            ${LibEvent_LIBRARIES}
        )

    if(GMP_FOUND)
        target_link_libraries(test_btcu ${GMP_LIBRARIES})
        target_include_directories(test_btcu PUBLIC ${GMP_INCLUDE_DIR})
    endif()
    if(ZMQ_FOUND)
        target_include_directories(test_btcu PUBLIC ${ZMQ_INCLUDE_DIRS} ${CMAKE_CURRENT_SOURCE_DIR}/src/cpp-ethereum/)
        target_link_libraries(test_btcu ZMQ_A ${ZMQ_LIBRARIES})
    endif()
    if(MINIUPNP_FOUND)
        target_compile_definitions(test_btcu PUBLIC "-DSTATICLIB -DMINIUPNP_STATICLIB")
        target_link_libraries(test_btcu ${MINIUPNP_LIBRARY})
        target_include_directories(test_btcu PUBLIC ${MINIUPNP_INCLUDE_DIR})
    endif()
    