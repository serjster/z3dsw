# Script-mode helper (cmake -P) run as the setup step of the coverage test
# fixture.
#
# Removes stale gcov counters (*.gcda) from the build tree. Without this, the
# coverage runtime tries to merge counters produced by an earlier, incompatible
# build and prints "cannot merge previous GCDA file: corrupt arc tag" for every
# test process.
if(NOT DEFINED BUILD_DIR)
	message(FATAL_ERROR "CoverageClean.cmake: BUILD_DIR is not set")
endif()

file(GLOB_RECURSE _gcda_files "${BUILD_DIR}/*.gcda")
if(_gcda_files)
	file(REMOVE ${_gcda_files})
endif()
