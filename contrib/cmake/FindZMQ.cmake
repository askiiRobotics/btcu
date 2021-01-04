# Copyright (c) 2017-2020 The Bitcoin developers
# Distributed under the MIT software license, see the accompanying
# file COPYING or http://www.opensource.org/licenses/mit-license.php.

# .rst:
# FindZMQ
# --------------
#
# Find the ZMQ library. The following conponents are
# available::
#   zmq
#
# This will define the following variables::
#
#   ZMQ_FOUND - True if the ZMQ library is found.
#   ZMQ_INCLUDE_DIRS - List of the header include directories.
#   ZMQ_LIBRARIES - List of the libraries.
#   ZMQ_VERSION - The library version MAJOR.MINOR.PATCH
#   ZMQ_VERSION_MAJOR - Major version number
#   ZMQ_VERSION_MINOR - Minor version number
#   ZMQ_VERSION_PATCH - Patch version number
#
# And the following imported targets::
#
#   ZMQ::zmq

find_path(ZMQ_INCLUDE_DIR
	NAMES zmq.h
)

set(ZMQ_INCLUDE_DIRS "${ZMQ_INCLUDE_DIR}")
mark_as_advanced(ZMQ_INCLUDE_DIR)

if(ZMQ_INCLUDE_DIR)
	# Extract version information from the zmq.h header.
	if(NOT DEFINED ZMQ_VERSION)
		# Read the version from file zmq.h into a variable.
		file(READ "${ZMQ_INCLUDE_DIR}/zmq.h" _ZMQ_HEADER)

		# Parse the version into variables.
		string(REGEX REPLACE
			".*ZMQ_VERSION_MAJOR[ \t]+([0-9]+).*" "\\1"
			ZMQ_VERSION_MAJOR
			"${_ZMQ_HEADER}"
		)
		string(REGEX REPLACE
			".*ZMQ_VERSION_MINOR[ \t]+([0-9]+).*" "\\1"
			ZMQ_VERSION_MINOR
			"${_ZMQ_HEADER}"
		)
		# Patch version example on non-crypto installs: x.x.xNC
		string(REGEX REPLACE
			".*ZMQ_VERSION_PATCH[ \t]+([0-9]+(NC)?).*" "\\1"
			ZMQ_VERSION_PATCH
			"${_ZMQ_HEADER}"
		)

		# Cache the result.
		set(ZMQ_VERSION_MAJOR ${ZMQ_VERSION_MAJOR}
			CACHE INTERNAL "ZMQ major version number"
		)
		set(ZMQ_VERSION_MINOR ${ZMQ_VERSION_MINOR}
			CACHE INTERNAL "ZMQ minor version number"
		)
		set(ZMQ_VERSION_PATCH ${ZMQ_VERSION_PATCH}
			CACHE INTERNAL "ZMQ patch version number"
		)
		# The actual returned/output version variable (the others can be used if
		# needed).
		set(ZMQ_VERSION
			"${ZMQ_VERSION_MAJOR}.${ZMQ_VERSION_MINOR}.${ZMQ_VERSION_PATCH}"
			CACHE INTERNAL "ZMQ full version"
		)
	endif()

	include(ExternalLibraryHelper)

	# The dependency to iphlpapi starts from 4.2.0
	if(ZMQ_VERSION VERSION_LESS 4.2.0)
		set(_ZMQ_WINDOWS_LIBRARIES "$<$<PLATFORM_ID:Windows>:ws2_32;rpcrt4>")
	else()
		set(_ZMQ_WINDOWS_LIBRARIES "$<$<PLATFORM_ID:Windows>:ws2_32;rpcrt4;iphlpapi>")
	endif()

	find_component(ZMQ zmq
		NAMES zmq
		INCLUDE_DIRS ${ZMQ_INCLUDE_DIRS}
		INTERFACE_LINK_LIBRARIES "${_ZMQ_WINDOWS_LIBRARIES}"
	)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZMQ
	REQUIRED_VARS ZMQ_INCLUDE_DIR
	VERSION_VAR ZMQ_VERSION
	HANDLE_COMPONENTS
)
