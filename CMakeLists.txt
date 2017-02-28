#  :copyright: (c) 2017 Alex Huszagh.
#  :license: BSD, see LICENSE.txt for more details.

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
option(USE_SYSTEM_ZLIB "Use system's Zlib library" ${UNIX})

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
    target_link_libraries(${output_name} libxlsxwriter ${ZLib_LIBRARIES})
    add_custom_target(check_${output_name}
        COMMAND $<TARGET_FILE:${output_name}>
        DEPENDS ${output_name}
    )
endmacro(CreateTest)


file(GLOB LXW_UTILITY_SOURCES test/unit/utility/test*.c)
file(GLOB LXW_XMLWRITER_SOURCES test/unit/xmlwriter/test*.c)
file(GLOB LXW_WORKSHEET_SOURCES test/unit/worksheet/test*.c)
file(GLOB LXW_SST_SOURCES test/unit/sst/test*.c)
file(GLOB LXW_WORKBOOK_SOURCES test/unit/workbook/test*.c)
file(GLOB LXW_APP_SOURCES test/unit/app/test*.c)
file(GLOB LXW_CONTENTTYPES_SOURCES test/unit/content_types/test*.c)

set(LXW_UNIT_SOURCES
    test/unit/test_all.c
    ${LXW_UTILITY_SOURCES}
    ${LXW_XMLWRITER_SOURCES}
    ${LXW_WORKSHEET_SOURCES}
    ${LXW_SST_SOURCES}
    ${LXW_WORKBOOK_SOURCES}
    ${LXW_APP_SOURCES}
    ${LXW_CONTENTTYPES_SOURCES}
)

if (BUILD_TESTS)
    if(USE_SYSTEM_ZLIB)
        enable_language(CXX)
        set(CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake ${CMAKE_MODULE_PATH})
        find_package(ZLib REQUIRED "1.0")
    else()
        if(NOT TARGET ZLib)
            add_subdirectory(zlib)
        endif()
    endif()

    add_definitions(-DTESTING -DCOLOR_OK)
    CreateTest(LXW_UNIT_SOURCES unit)
endif()

# EXAMPLES
# --------
