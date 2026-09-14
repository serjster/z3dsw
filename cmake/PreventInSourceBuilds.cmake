# Fail fast if someone tries to build inside the source tree.
include_guard(GLOBAL)

if(CMAKE_SOURCE_DIR STREQUAL CMAKE_BINARY_DIR)
	message(
		FATAL_ERROR
			"In-source builds are not allowed.\n"
			"Create a separate build directory, e.g.:\n"
			"  cmake -S . -B build -G Ninja\n"
			"  cmake --build build\n"
			"Or use a preset: cmake --preset debug && cmake --build --preset debug\n"
			"Remove the stray CMakeCache.txt / CMakeFiles/ if they were created.")
endif()
