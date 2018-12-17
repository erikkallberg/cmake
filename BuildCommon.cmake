if(NOT DEFINED PROJECT_NAME)
    message(FATAL_ERROR "PROJECT_NAME variable is not defined")
endif()

if(NOT DEFINED PROJECT_VERSION)
    message(FATAL_ERROR "PROJECT_VERSION variable is not defined")
endif()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/versioninfo.txt" "${PROJECT_VERSION}")

add_definitions(-DPROJECT_NAME="${PROJECT_NAME}")
add_definitions(-DPROJECT_VERSION="${PROJECT_VERSION}")

include_directories("${PROJECT_SOURCE_DIR}")

unset(CMAKE_C_FLAGS CACHE)
set(CMAKE_C_FLAGS "-Wall -Wextra -Wpedantic -Wno-unused-parameter")

unset(CMAKE_CXX_FLAGS CACHE)
set(CMAKE_CXX_FLAGS "-std=c++11 -Wall -Wextra -Wpedantic -Wno-unused-parameter")

if(NOT CMAKE_BUILD_TYPE)
# Had some problem with googletest build when Debug build so therefore it is set to Release
#    set(CMAKE_BUILD_TYPE Debug)
    set(CMAKE_BUILD_TYPE Release)
endif()

set(CMAKE_C_FLAGS_RELEASE "-O2 -DNDEBUG -s")
set(CMAKE_CXX_FLAGS_RELEASE "-O2 -DNDEBUG -s")

set(CMAKE_C_FLAGS_MINSIZEREL "${CMAKE_C_FLAGS_MINSIZEREL} -s")
set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS_MINSIZEREL} -s")

message(STATUS "Build type of \"${PROJECT_NAME}\" is set to: ${CMAKE_BUILD_TYPE}")
