# Copyright (c) 2017-2019 The BTCU developers

# This generates config.h which provides numerous defines
# about the state of the plateform we are building on.

include(CheckIncludeFiles)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CheckCXXSymbolExists)
include(CheckCXXSourceCompiles)
include(TestBigEndian)

# Version
set(CLIENT_VERSION_MAJOR ${btcu_VERSION_MAJOR})
set(CLIENT_VERSION_MINOR ${btcu_VERSION_MINOR})
set(CLIENT_VERSION_REVISION ${btcu_VERSION_PATCH})

option(CLIENT_VERSION_IS_RELEASE "Build a release version" OFF)

# AVX2
string(JOIN " " CMAKE_REQUIRED_FLAGS ${CRYPTO_AVX2_FLAGS})
check_cxx_source_compiles("
	#include <stdint.h>
	#include <immintrin.h>
	int main() {
		__m256i l = _mm256_set1_epi32(0);
		return _mm256_extract_epi32(l, 7);
	}
" ENABLE_AVX2)

# SHA-NI
string(JOIN " " CMAKE_REQUIRED_FLAGS ${CRYPTO_SHANI_FLAGS})
check_cxx_source_compiles("
	#include <stdint.h>
	#include <immintrin.h>
	int main() {
		__m128i i = _mm_set1_epi32(0);
		__m128i j = _mm_set1_epi32(1);
		__m128i k = _mm_set1_epi32(2);
		return _mm_extract_epi32(_mm_sha256rnds2_epu32(i, i, k), 0);
	}
" ENABLE_SHANI)

# SSE4.1
string(JOIN " " CMAKE_REQUIRED_FLAGS ${CRYPTO_SSE41_FLAGS})
check_cxx_source_compiles("
	#include <stdint.h>
	#include <immintrin.h>
	int main() {
		__m128i l = _mm_set1_epi32(0);
		return _mm_extract_epi32(l, 3);
	}
" ENABLE_SSE41)

#__fdelt_chk's params and return type have changed from long unsigned int to
# long int. See which one is present here.
include(CheckPrototypeDefinition)

set(CMAKE_REQUIRED_DEFINITIONS -D_FORTIFY_SOURCE=2)
# Without some optimization the compiler won't detect the prototype conflict
# and always succeed to build.
set(CMAKE_REQUIRED_FLAGS -O2)

check_prototype_definition(
	__fdelt_warn
	"extern long unsigned int __fdelt_warn(long unsigned int a)"
	"0"
	"sys/select.h"
	FDELT_PROTOTYPE_LONG_UNSIGNED_INT
)

if(FDELT_PROTOTYPE_LONG_UNSIGNED_INT)
	set(FDELT_TYPE "long unsigned int")
else()
	set(FDELT_TYPE "long int")
endif()

# Set flag is boost & required components installed
set(HAVE_BOOST ${Boost_FOUND})
set(HAVE_BOOST_CHRONO ${Boost_chrono_FOUND})
set(HAVE_BOOST_FILESYSTEM ${Boost_filesystem_FOUND})
set(HAVE_BOOST_LOG ${Boost_log_FOUND})
set(HAVE_BOOST_PROGRAM_OPTIONS ${Boost_program_options_FOUND})
set(HAVE_BOOST_SYSTEM ${Boost_system_FOUND})
set(HAVE_BOOST_THREAD ${Boost_thread_FOUND})
set(HAVE_BOOST_UNIT_TEST_FRAMEWORK ${Boost_unit_test_framework_FOUND})

# Check is the consensus lib has been built
set(HAVE_CONSENSUS_LIB ${BUILD_LIBS})

# Byte swap
check_include_files("byteswap.h" HAVE_BYTESWAP_H)

check_symbol_exists(bswap_16 "byteswap.h" HAVE_DECL_BSWAP_16)
check_symbol_exists(bswap_32 "byteswap.h" HAVE_DECL_BSWAP_32)
check_symbol_exists(bswap_64 "byteswap.h" HAVE_DECL_BSWAP_64)

# Endianness
check_include_files("endian.h" HAVE_ENDIAN_H)
check_include_files("sys/endian.h" HAVE_SYS_ENDIAN_H)

if(HAVE_ENDIAN_H)
	set(ENDIAN_FILE "endian.h")
elseif(HAVE_SYS_ENDIAN_H)
	set(ENDIAN_FILE "sys/endian.h")
else()
endif()

if(ENDIAN_FILE)
	check_symbol_exists(htole16 ${ENDIAN_FILE} HAVE_DECL_HTOLE16)
	check_symbol_exists(htobe16 ${ENDIAN_FILE} HAVE_DECL_HTOBE16)
	check_symbol_exists(be16toh ${ENDIAN_FILE} HAVE_DECL_BE16TOH)
	check_symbol_exists(le16toh ${ENDIAN_FILE} HAVE_DECL_LE16TOH)
	check_symbol_exists(htobe32 ${ENDIAN_FILE} HAVE_DECL_HTOBE32)
	check_symbol_exists(htole32 ${ENDIAN_FILE} HAVE_DECL_HTOLE32)
	check_symbol_exists(be32toh ${ENDIAN_FILE} HAVE_DECL_BE32TOH)
	check_symbol_exists(le32toh ${ENDIAN_FILE} HAVE_DECL_LE32TOH)
	check_symbol_exists(htobe64 ${ENDIAN_FILE} HAVE_DECL_HTOBE64)
	check_symbol_exists(htole64 ${ENDIAN_FILE} HAVE_DECL_HTOLE64)
	check_symbol_exists(be64toh ${ENDIAN_FILE} HAVE_DECL_BE64TOH)
	check_symbol_exists(le64toh ${ENDIAN_FILE} HAVE_DECL_LE64TOH)
endif()

#  check strerror_r
CHECK_FUNCTION_EXISTS(strerror_r HAVE_STRERROR_R)

IF(HAVE_STRERROR_R)
  SET(HAVE_DECL_STRERROR_R 1)
ENDIF()

# <dlfcn.h> header file
check_include_file(dlfcn.h HAVE_DLFCN_H)

# <inttypes.h> header file
check_include_file(inttypes.h HAVE_INTTYPES_H)


# sys/select.h and sys/prctl.h headers
check_include_files("sys/select.h" HAVE_SYS_SELECT_H)
check_include_files("sys/prctl.h" HAVE_SYS_PRCTL_H)

# Bitmanip intrinsics
function(check_builtin_exist SYMBOL VARIABLE)
	set(
		SOURCE_FILE
		"${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/CheckBuiltinExists.c"
	)
	set(
		CMAKE_CONFIGURABLE_FILE_CONTENT
		"int main(int argc, char** argv) { (void)argv; return ${SYMBOL}(argc); }\n"
	)
	configure_file(
		"${CMAKE_ROOT}/Modules/CMakeConfigurableFile.in"
		"${SOURCE_FILE}"
		@ONLY
	)
	if(NOT CMAKE_REQUIRED_QUIET)
		message(STATUS "Looking for ${SYMBOL}")
	endif()
	try_compile(${VARIABLE}
		${CMAKE_BINARY_DIR}
		${SOURCE_FILE}
		OUTPUT_VARIABLE OUTPUT
	)
	if(${VARIABLE})
		if(NOT CMAKE_REQUIRED_QUIET)
			message(STATUS "Looking for ${SYMBOL} - found")
		endif()
		set(${VARIABLE} 1 CACHE INTERNAL "Have symbol ${SYMBOL}" PARENT_SCOPE)
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeOutput.log
			"Determining if the ${SYMBOL} "
			"exist passed with the following output:\n"
			"${OUTPUT}\nFile ${SOURCEFILE}:\n"
			"${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
	else()
		if(NOT CMAKE_REQUIRED_QUIET)
			message(STATUS "Looking for ${SYMBOL} - not found")
		endif()
		set(${VARIABLE} "" CACHE INTERNAL "Have symbol ${SYMBOL}" PARENT_SCOPE)
		file(APPEND ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeError.log
			"Determining if the ${SYMBOL} "
			"exist failed with the following output:\n"
			"${OUTPUT}\nFile ${SOURCEFILE}:\n"
			"${CMAKE_CONFIGURABLE_FILE_CONTENT}\n")
	endif()
endfunction()

check_builtin_exist(__builtin_clz HAVE_DECL___BUILTIN_CLZ)
check_builtin_exist(__builtin_clzl HAVE_DECL___BUILTIN_CLZL)
check_builtin_exist(__builtin_clzll HAVE_DECL___BUILTIN_CLZLL)
check_builtin_exist(__builtin_popcount HAVE_BUILTIN_POPCOUNT)

# Memory management capabilities
check_symbol_exists(M_ARENA_MAX "malloc.h" HAVE_MALLOPT_ARENA_MAX)
check_symbol_exists(malloc_info "malloc.h" HAVE_MALLOC_INFO)

# Various system libraries
check_symbol_exists(strnlen "string.h" HAVE_DECL_STRNLEN)
# daemon() is located in unistd.h on linux and in stdlib.h on BSDs and macOS.
check_symbol_exists(daemon "unistd.h;stdlib.h" HAVE_DECL_DAEMON)

# Check for ways to obtain entropy
check_symbol_exists(getentropy "unistd.h" HAVE_GETENTROPY)
# macOS needs unistd.h and sys/random.h to define getentropy
check_symbol_exists(getentropy "unistd.h;sys/random.h" HAVE_GETENTROPY_RAND)

# OSX and BSDs measurement related headers
check_include_files("sys/types.h;vm/vm_params.h" HAVE_VM_VM_PARAM_H)
check_include_files("sys/types.h;sys/vmmeter.h" HAVE_SYS_VMMETER_H)
check_include_files("sys/types.h;sys/resources.h" HAVE_SYS_RESOURCES_H)

# Don't use sysctl on Linux, it's deprecated even when it works
if(NOT ${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	check_symbol_exists(sysctl "sys/types.h;sys/sysctl.h" HAVE_SYSCTL)
endif()

# getifaddrs and freeifaddrs may be unavailable with some Android versions
check_symbol_exists(getifaddrs "sys/types.h;ifaddrs.h" HAVE_DECL_GETIFADDRS)
check_symbol_exists(freeifaddrs "sys/types.h;ifaddrs.h" HAVE_DECL_FREEIFADDRS)

check_cxx_source_compiles("
	#include <unistd.h>  /* for syscall */
	#include <sys/syscall.h>  /* for SYS_getrandom */
	#include <linux/random.h>
	int main() {
		syscall(SYS_getrandom, nullptr, 0, 0);
		return 0;
	}
" HAVE_SYS_GETRANDOM)

check_cxx_source_compiles("
	#include <sys/types.h>
	#include <sys/sysctl.h>
	int main() {
		static const int name[2] = {CTL_KERN, KERN_ARND};
		sysctl(name, 2, nullptr, nullptr, nullptr, 0);
		return 0;
	}
" HAVE_SYSCTL_ARND)

check_cxx_source_compiles("
    #include <sys/types.h>
    #include <type_traits>
    int main() {
        static_assert(sizeof(off_t) == 8, \"\");
        return 0;
    }
" HAVE_LARGE_FILE_SUPPORT)

check_cxx_source_compiles("
    __attribute__((visibility(\"default\"))) int main() {
        return 0;
    }
" HAVE_FUNC_ATTRIBUTE_VISIBILITY)

check_cxx_source_compiles("
    __declspec(dllexport) int main() {
        return 0;
    }
" HAVE_FUNC_ATTRIBUTE_DLLEXPORT)

check_cxx_source_compiles("
    __declspec(dllimport) int main() {
        return 0;
    }
" HAVE_FUNC_ATTRIBUTE_DLLIMPORT)

# Check for the `advapi32' library (-ladvapi32)
check_library_exists(advapi32 ${ADVAPI32_LIBRARY} HAVE_LIBADVAPI32)

# Check for the `comctl32' library (-lcomctl32)
check_library_exists(comctl32 ${COMCTL32_LIBRARY} HAVE_LIBCOMCTL32)

# Check for the `comdlg32' library (-lcomdlg32)
check_library_exists(comdlg32 ${COMDLG32_LIBRARY} HAVE_LIBCOMDLG32)

# Check for the `crypt32' library (-lcrypt32)
check_library_exists(crypt32 ${CRYPT32_LIBRARY} HAVE_LIBCRYPT32)

# Check for the `gdi32' library (-lgdi32)
check_library_exists(gdi32 ${GDI32_LIBRARY} HAVE_LIBGDI32)

# Set flag is libgmp installed
set(HAVE_LIBGMP ${GMP_FOUND})

# Check for the `imm32' library (-limm32).
check_library_exists(imm32 ${IMM32_LIBRARY} HAVE_LIBIMM32)

# Check for the `iphlpapi' library (-liphlpapi).
check_library_exists(iphlpapi ${IPHLPAPI_LIBRARY} HAVE_LIBIPHLPAPI)

# Check for the `kernel32' library (-lkernel32).
check_library_exists(kernel32 ${KERNEL32_LIBRARY} HAVE_LIBKERNEL32)

# Check for the `mingwthrd' library (-lmingwthrd).
check_library_exists(mingwthrd ${MINGWTHRD_LIBRARY} HAVE_LIBMINGWTHRD)

# Check for the `mswsock' library (-lmswsock).
check_library_exists(mswsock ${MSWSOCK_LIBRARY} HAVE_LIBMSWSOCK)

# Check for the `ole32' library (-lole32).
check_library_exists(ole32 ${OLE32_LIBRARY} HAVE_LIBOLE32)

# Check for the `oleaut32' library (-loleaut32).
check_library_exists(oleaut32 ${OLEAUT32_LIBRARY} HAVE_LIBOLEAUT32)

# Check for the `rpcrt4' library (-lrpcrt4).
check_library_exists(rpcrt4 ${RPCRT4_LIBRARY} HAVE_LIBRPCRT4)

# Check for the `rt' library (-lrt).
check_library_exists(rt ${RT_LIBRARY} HAVE_LIBRT)

# Check for the `shell32' library (-lshell32).
check_library_exists(shell32 ${SHELL32_LIBRARY} HAVE_LIBSHELL32)

# Check for the `shlwapi' library (-lshlwapi).
check_library_exists(shlwapi ${SHLWAPI_LIBRARY} HAVE_LIBSHLWAPI)

# Check for the `ssp' library (-lssp).
check_library_exists(ssp ${SSP_LIBRARY} HAVE_LIBSSP)

# Check for the `user32' library (-luser32).
check_library_exists(user32 ${USER32_LIBRARY} HAVE_LIBUSER32)

# Check for the `uuid' library (-luuid).
check_library_exists(uuid ${UUID_LIBRARY} HAVE_LIBUUID)

# Check for the `winmm' library (-lwinmm).
check_library_exists(winmm ${WINMM_LIBRARY} HAVE_LIBWINMM)

# Check for the `winspool' library (-lwinspool).
check_library_exists(winspool ${WINSPOOL_LIBRARY} HAVE_LIBWINSPOOL)

# Check for the `ws2_32' library (-lws2_32).
check_library_exists(ws2_32 ${WS2_32_LIBRARY} HAVE_LIBWS2_32)

# Check for the `z ' library (-lz ).
check_library_exists('z ${Z_LIBRARY} HAVE_LIBZ_)

# <memory.h> header file
check_include_files("memory.h" HAVE_MEMORY_H)

# <miniupnpc/miniupnpc.h> header file
check_include_files("miniupnpc/miniupnpc.h" HAVE_MINIUPNPC_MINIUPNPC_H)

# <miniupnpc/miniwget.h> header file.
check_include_files("miniupnpc/miniwget.h" HAVE_MINIUPNPC_MINIWGET_H)

# <miniupnpc/upnpcommands.h> header file.
check_include_files("miniupnpc/upnpcommands.h" HAVE_MINIUPNPC_UPNPCOMMANDS_H)

# <miniupnpc/upnperrors.h> header file.
check_include_files("miniupnpc/upnperrors.h" HAVE_MINIUPNPC_UPNPERRORS_H)

# check for the MSG_DONTWAIT
check_cxx_source_compiles("
    #include <sys/socket.h>
    int main() {
        int f = MSG_DONTWAIT;
        return 0;
    }
" HAVE_MSG_DONTWAIT)

# check for the MSG_NOSIGNAL
check_cxx_source_compiles("
    #include <sys/socket.h>
    int main() {
        int f = MSG_NOSIGNAL;
        return 0;
    }
" HAVE_MSG_NOSIGNAL)

# check if you have POSIX threads libraries and header files
if(Threads_FOUND)
    set(HAVE_PTHREAD 1)
endif()

# check PTHREAD_PRIO_INHERIT
check_symbol_exists(PTHREAD_PRIO_INHERIT pthread.h HAVE_PTHREAD_PRIO_INHERIT)

# <stdint.h> header file
check_include_files(stdint.h HAVE_STDINT_H)

# <stdio.h> header file
check_include_files(stdio.h HAVE_STDIO_H)

# <stdlib.h> header file
check_include_files(stdlib.h HAVE_STDLIB_H)

# `strerror_r' function
check_function_exists(strerror_r HAVE_STRERROR_R)

# <strings.h> header file
check_include_files(strings.h HAVE_STRINGS_H)

# <string.h> header file
check_include_files(string.h HAVE_STRING_H)

# <sys/stat.h> header file
check_include_files(sys/stat.h HAVE_SYS_STAT_H)

# <sys/types.h> header file
check_include_files(sys/types.h HAVE_SYS_TYPES_H)

# check is thread_local supported
check_cxx_source_compiles("
	#if defined(_MSC_VER) && !defined(__thread)
	#define __thread __declspec(thread)
	#endif
	int main() {
	static __thread int tls;
	}
" HAVE_THREAD_LOCAL)

# <unistd.h> header file
check_include_files(unistd.h HAVE_UNISTD_H)

# check is the visibility attribute supported
check_c_source_compiles("
	#include <stdlib.h>
	static void foo(void) __attribute__ ((visibility(\"default\")));
	int main(void) { return 0; }
" HAVE_VISIBILITY_ATTRIBUTE)

# check is boost sleep works
check_cxx_source_compiles("
	#include <boost/thread.hpp>
	#include <boost/date_time/posix_time/posix_time_types.hpp>
    void func() { boost::this_thread::sleep(boost::posix_time::milliseconds(0)); }
    int main() { return 0; }
" HAVE_WORKING_BOOST_SLEEP)

# check is boost sleep_for works
check_cxx_source_compiles("
	#include <boost/thread/thread.hpp>
	#include <boost/version.hpp>
    void func() { boost::this_thread::sleep_for(boost::chrono::milliseconds(0)); }
    int main() { return 0; }
" HAVE_WORKING_BOOST_SLEEP_FOR)

# the sub-directory where libtool stores uninstalled libraries
set(LT_OBJDIR ".libs/")

# the version of this package
set(PACKAGE_VERSION 3.0.2)

# full name and version of this package
set(PACKAGE_STRING "${PROJECT_NAME} ${PACKAGE_VERSION}")

# short name of this package
set(PACKAGE_TARNAME ${PROJECT_NAME})

# the home page for this package
set(PACKAGE_URL "https://btcu.io/")

# Define to necessary symbol if this constant
# uses a non-standard name on your system
set(ATTR_NAME "UNKNOWN")
foreach(PTHREAD_TEST PTHREAD_CREATE_JOINABLE PTHREAD_CREATE_UNDETACHED)
	check_cxx_source_compiles("
		#include <pthread.h>
		int main() {
			int attr = ${PTHREAD_TEST};
			return 0;
		}
		" IS_SUCCESSED)
	if(IS_SUCCESSED)
		set(ATTR_NAME "${PTHREAD_TEST}")
		break()
	endif()
endforeach(PTHREAD_TEST)

if("${ATTR_NAME}" STREQUAL "${PTHREAD_CREATE_JOINABLE}")
	set(PTHREAD_CREATE_JOINABLE "${ATTR_NAME}")
endif()

# check is qt platform cocoa
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(QT_QPA_PLATFORM_COCOA 1)
endif()

# check is the minimal qt platform exists
if(Qt5Core_FOUND)
	set(QT_QPA_PLATFORM_MINIMAL 1)
endif()

# check is it the windows qt platform
if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
	set(QT_QPA_PLATFORM_WINDOWS 1)
endif()

# check is it the xcb qt platform
if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
	set(QT_QPA_PLATFORM_XCB 1)
endif()

# check are qt plugins static
# TODO: add support for QT_STATIC_BUILD
if(QT_STATIC_BUILD)
	set(QT_STATICPLUGIN 1)
endif()

# check do you have the ANSI C header files
check_include_files("stdlib.h;stdarg.h;string.h;float.h" STDC_HEADERS)

# check is strerror_r returns char *.
check_cxx_source_compiles("
  #include <string.h>
  int main() { char x = *strerror_r(0, &x, sizeof(x)); return 0; }
  " STRERROR_R_CHAR_P)

# check should it build in assembly routines
set(USE_ASM ${ENABLE_ASM})

# check is coverage enabled
set(USE_COVERAGE ${ENABLE_COVERAGE})

# check is dbus support should be compiled in
if(ENABLE_DBUS_NOTIFICATIONS)
	set(USE_DBUS 1)
endif()

# check is gmp was found
if(GMP_FOUND)
    set(USE_NUM_GMP 1)
elseif(OPENSSL_FOUND)
    message(WARNING "GMP not found, falling back to OpenSSL for bignum!")
	set(USE_NUM_OPENSSL 1)
else()
    message(WARNING "There is no suitable lib for bugnum!")
endif()

# check is QTCHARTS support should be compiled in
if(ENABLE_QTCHARTS AND Qt5Charts_FOUND)
	set(USE_QTCHARTS 1)
endif()

# check is enabled UPnP support
if(WITH_MINIUNPC AND MINIUPNP_FOUND)
	set(ENABLE_UPNP 1)
endif()

# Try to find miniupnpc
if(ENABLE_UPNP)
	# The expected behavior is as follow:
	#  - If UPnP is enabled USE_UPNP must be defined
	#  - If UPnP should be the default port map method, USE_UPNP should be
	#    defined to 1, otherwise it should be defined to 0.
	set(USE_UPNP ${START_WITH_UPNP} CACHE INTERNAL "UPnP is enabled")
endif()

# check your processor stores words with the most
#   significant byte first (like Motorola and SPARC, unlike Intel).
test_big_endian(WORDS_BIGENDIAN)

# check is large inode numbers on Mac OS X 10.5 should be enabled
if(${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
	set(_DARWIN_USE_64_BIT_INODE 1)
endif()

# Enable LFS (Large File Support) on targets that don't have it natively.
# This should be defined before the libraries are included as leveldb need the
# definition to be set.
if(NOT HAVE_LARGE_FILE_SUPPORT)
	set(_FILE_OFFSET_BITS 64)
	add_compile_definitions(_FILE_OFFSET_BITS=64)
	add_linker_flags(-Wl,--large-address-aware)
else()
	set(_LARGE_FILES 1)
endif()


# Check if std::system or ::wsystem is available
check_cxx_symbol_exists(std::system "cstdlib" _HAVE_STD_SYSTEM)
check_cxx_symbol_exists(::wsystem "" _HAVE_WSYSTEM)
if(_HAVE_STD_SYSTEM OR _HAVE_WSYSTEM)
	set(HAVE_SYSTEM 1)
endif()

# Generate the config
configure_file(btcu-config.h.cmake.in btcu-config.h ESCAPE_QUOTES)
