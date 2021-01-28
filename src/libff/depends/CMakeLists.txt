if(${CURVE} STREQUAL "BN128")
  if(${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    project(zm)
  endif()

  include_directories(ate-pairing/include)
  include_directories(xbyak)
  add_library(
    zm

    ate-pairing/src/zm.cpp
    ate-pairing/src/zm2.cpp
  )
endif()
