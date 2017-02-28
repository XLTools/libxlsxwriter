#  :copyright: (c) 2017 Alex Huszagh.
#  :license: BSD, see LICENSE.txt for more details.

# FindZLib
# --------
#
# Find ZLib include dirs and libraries
#
# Use this module by invoking find_package with the form::
#
#   find_package(ZLib
#     [version] [EXACT]      # Minimum or EXACT version e.g. 1.0.6
#     [REQUIRED]             # Fail with error if ZLib is not found
#     )
#
# You may also set `ZLib_USE_STATIC_LIBS` to prefer static libraries
# to shared ones.
#
# If found, `ZLib_FOUND` will be set to true, and `ZLib_LIBRARIES`
# and `ZLib_INCLUDE_DIRS` will both be set.

include(CheckCXXSourceCompiles)
include(FindPackage)

# REPEAT
# ------

ReturnFound(ZLib)

# SUFFIXES
# --------

SetSuffixes(ZLib)

# FIND
# ----

FIND_PATH(ZLib_INCLUDE_DIRS zlib.h)
FIND_LIBRARY(ZLib_LIBRARIES
    NAMES z libz zlib zlib1
    DOC "ZLib library path"
)

CheckFound(ZLib)
FindStaticLibs(ZLib)

# VERSION
# -------

if(ZLib_FOUND)
    file(STRINGS "${ZLib_INCLUDE_DIRS}/zlib.h" ZLib_VERSION_CONTENTS REGEX "#define ZLIB_VERSION \"[0-9]+\\.[0-9]+\\.[0-9]+\"")
    string(REGEX REPLACE ".*ZLIB_VERSION \"([0-9]+)\\.[0-9]+\\.[0-9]+\"" "\\1" ZLib_VERSION_MAJOR "${ZLib_VERSION_CONTENTS}")
    string(REGEX REPLACE ".*ZLIB_VERSION \"[0-9]+\\.([0-9]+)\\.[0-9]+\"" "\\1" ZLib_VERSION_MINOR "${ZLib_VERSION_CONTENTS}")
    string(REGEX REPLACE ".*ZLIB_VERSION \"[0-9]+\\.[0-9]+\\.([0-9]+)\"" "\\1" ZLib_VERSION_PATCH "${ZLib_VERSION_CONTENTS}")

    set(ZLib_VERSION_STRING "${ZLib_VERSION_MAJOR}.${ZLib_VERSION_MINOR}.${ZLib_VERSION_PATCH}")
    set(ZLib_VERSION ${ZLib_VERSION_STRING})

    MatchVersion(ZLib)
endif()

# COMPILATION
# -----------

set(ZLib_CODE "
#include <zlib.h>
int main(void)
{
    const char *version;
    version  = zlibVersion();

    return 0;
}
"
)

if(ZLib_FOUND)
    CheckCompiles(ZLib)
endif()


# REQUIRED
# --------

RequiredPackageFound(ZLib)
