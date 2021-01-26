# Find the RocksDB libraries
#
# The following variables are optionally searched for defaults
#  ROCKSDB_ROOT_DIR:    Base directory where all RocksDB components are found
#
# The following are set after configuration is done:
#  rocksdb_FOUND
#  RocksDB_INCLUDE_DIR
#  ROCKSDB_LIBRARY

find_path(RocksDB_INCLUDE_DIR NAMES rocksdb/db.h
                             PATHS ${ROCKSDB_ROOT_DIR} ${ROCKSDB_ROOT_DIR}/include /usr/include /usr/local/include)

find_library(ROCKSDB_LIBRARY NAMES rocksdb rocksdbd librocksdb
                              PATHS ${ROCKSDB_ROOT_DIR} ${ROCKSDB_ROOT_DIR}/lib /usr/lib /usr/local/lib)

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(RocksDB DEFAULT_MSG RocksDB_INCLUDE_DIR ROCKSDB_LIBRARY)

if(rocksdb_FOUND)
  message(STATUS "Found RocksDB  (include: ${RocksDB_INCLUDE_DIR}, library: ${ROCKSDB_LIBRARY})")
  mark_as_advanced(RocksDB_INCLUDE_DIR ROCKSDB_LIBRARY)
endif()
