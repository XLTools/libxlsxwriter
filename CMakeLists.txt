#  :copyright: (c) 2017 Alex Huszagh.
#  :license: FreeBSD, see LICENSE.txt for more details.

cmake_minimum_required(VERSION 2.8)
project(xlsxwriter C)

# VERSION
# -------

set(LXW_VERSION include/xlsxwriter.h)
file(STRINGS "${LXW_VERSION}" LXW_VERSION_CONTENTS REGEX "#define LXW_VERSION \"[0-9]+\\.[0-9]+\\.[0-9]+\"")

string(REGEX REPLACE ".*LXW_VERSION \"([0-9]+).*" "\\1" LXW_VERSION_MAJOR "${LXW_VERSION_CONTENTS}")
string(REGEX REPLACE ".*LXW_VERSION \"[0-9]+\\.([0-9]+).*" "\\1" LXW_VERSION_MINOR "${LXW_VERSION_CONTENTS}")
string(REGEX REPLACE ".*LXW_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+).*" "\\1" LXW_VERSION_PATCH "${LXW_VERSION_CONTENTS}")

# OPTIONS
# -------

option(BUILD_STATIC "Build static libxlsxwriter" ON)
option(BUILD_TESTS "Build libxlsxwriter tests" OFF)
option(BUILD_EXAMPLES "Build libxlsxwriter examples" OFF)
option(USE_STANDARD_TMPFILE "Use the C standard library's tmpfile()" ON)

if(USE_STANDARD_TMPFILE)
    add_definitions(-DUSE_STANDARD_TMPFILE)
endif()

if(BUILD_STATIC)
    if(UNIX)
        set(CMAKE_POSITION_INDEPENDENT_CODE ON)
    elseif(${MINGW} OR ${MSYS}})
        set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -static -static-libgcc -Wno-char-subscripts -Wno-long-long")
        add_definitions(-DUSE_FILE32API)
    elseif(MSVC)
        set(CMAKE_C_FLAGS_DEBUG "${CMAKE_C_FLAGS_RELEASE} /MTd /O0")
        set(CMAKE_C_FLAGS_RELEASE "${CMAKE_C_FLAGS_RELEASE} /MT /Ox")
    endif()
endif()

# LIBRARY
# -------

add_definitions(-DNOCRYPT -DNOUNCRYPT)

include_directories(include include/xlsxwriter)
file(GLOB LXW_SOURCES src/*.c)
list(APPEND LXW_SOURCES third_party/minizip/ioapi.c third_party/minizip/zip.c)
if (USE_STANDARD_TMPFILE)
    include_directories(third_party/tmpfileplus)
    list(APPEND LXW_SOURCES third_party/tmpfileplus/tmpfileplus.c)
endif()

set(LXW_PROJECT_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
set(LXW_LIB_DIR "${LXW_PROJECT_DIR}/lib")

if(BUILD_STATIC)
    add_library(libxlsxwriter STATIC ${LXW_SOURCES})
else()
    add_library(libxlsxwriter SHARED ${LXW_SOURCES})
endif()

# TESTS
# -----

# Create test and runner.
#
# Args:
#   sources       Name of variable holding source files
#   target        Test name
#
macro(CreateTest sources target)
    set(output_name libxlsxwriter_${target})
    add_executable(${output_name} ${${sources}})
    target_link_libraries(${output_name} libxlsxwriter)
    add_custom_target(check_${output_name}
        COMMAND $<TARGET_FILE:${output_name}>
        DEPENDS ${output_name}
    )
endmacro(CreateTest)


file(GLOB LXW_UTILITY_SOURCES test/unit/utility/*.c)

if (BUILD_TESTS)
    CreateTest(LXW_UTILITY_SOURCES utility)
endif()

# EXAMPLES
# --------
