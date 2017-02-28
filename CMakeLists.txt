#  :copyright: (c) 2015-2017 The Regents of the University of California.
#  :license: FreeBSD, see LICENSE.txt for more details.

cmake_minimum_required(VERSION 2.8)
project(xlsxwriter C)


set(LXW_VERSION include/xlsxwriter.h)
file(STRINGS "${LXW_VERSION}" LXW_VERSION_CONTENTS REGEX "#define LXW_VERSION \"[0-9]+\.[0-9]+\.[0-9]+\"")
message(${LXW_VERSION_CONTENTS})
##include "xlsxwriter/worksheet.h"
#18  #include "xlsxwriter/format.h"
#19  #include "xlsxwriter/utility.h"
#20
#21  #define LXW_VERSION "0.6.9
