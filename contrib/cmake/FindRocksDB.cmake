# .rst:
# FindRocksDB
# --------------
# Find the RocksDB libraries
#
# The following variables are optionally searched for defaults
#  ROCKSDB_ROOT_DIR:    Base directory where all RocksDB components are found
#
# The following are set after configuration is done:
#  RocksDB_FOUND
#  RocksDB_INCLUDE_DIR
#  ROCKSDB_LIBRARY

message(STATUS "Into rocksdb cmake find")
find_path(RocksDB_INCLUDE_DIR NAMES rocksdb/db.h
                             PATHS ${ROCKSDB_ROOT_DIR} ${ROCKSDB_ROOT_DIR}/include /usr/include /usr/local/include)

message(STATUS RocksDB_INCLUDE_DIR:)
message(STATUS ${RocksDB_INCLUDE_DIR})

if(RocksDB_INCLUDE_DIR)
	find_component(RocksDB rocksdb
		NAMES
            rocksdb rocksdbd librocksdb
			libzmq
		INCLUDE_DIRS ${RocksDB_INCLUDE_DIR}
	)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RocksDB
	REQUIRED_VARS RocksDB_INCLUDE_DIR
	HANDLE_COMPONENTS
)

if(RocksDB_FOUND)
  set(ZeroMQ_INCLUDE_DIR "${RocksDB_INCLUDE_DIRS}")
  set(ROCKSDB_LIBRARY "${RocksDB_LIBRARIES}")

  message(STATUS "Found RocksDB  (include: ${RocksDB_INCLUDE_DIR}, library: ${ROCKSDB_LIBRARY})")
  mark_as_advanced(RocksDB_INCLUDE_DIR ROCKSDB_LIBRARY)
endif()
