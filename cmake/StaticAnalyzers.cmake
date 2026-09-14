# Wires clang-tidy and/or cppcheck into the build via the standard
# CMAKE_CXX_CLANG_TIDY / CMAKE_CXX_CPPCHECK hooks. Must be included BEFORE any
# target is declared so the analyzers run as part of compilation.
include_guard(GLOBAL)

if(Z3D_ENABLE_CLANG_TIDY)
	find_program(
		Z3D_CLANG_TIDY
		NAMES clang-tidy clang-tidy-19 clang-tidy-18 clang-tidy-17
		HINTS ${Z3D_LLVM_TOOL_HINTS})
	if(Z3D_CLANG_TIDY)
		set(_tidy_cmd "${Z3D_CLANG_TIDY}")
		if(Z3D_WARNINGS_AS_ERRORS)
			list(APPEND _tidy_cmd "--warnings-as-errors=*")
		endif()
		set(CMAKE_CXX_CLANG_TIDY ${_tidy_cmd})
		message(STATUS "z3dsw: clang-tidy -> ${Z3D_CLANG_TIDY}")
	else()
		message(
			WARNING
				"z3dsw: Z3D_ENABLE_CLANG_TIDY=ON but clang-tidy was not found. "
				"Install it (e.g. 'brew install llvm' or 'apt install clang-tidy') "
				"or point CMake at it with -DZ3D_CLANG_TIDY=/path/to/clang-tidy."
		)
	endif()
endif()

if(Z3D_ENABLE_CPPCHECK)
	find_program(Z3D_CPPCHECK NAMES cppcheck)
	if(Z3D_CPPCHECK)
		set(CMAKE_CXX_CPPCHECK
			${Z3D_CPPCHECK}
			--enable=warning,style,performance,portability
			--inline-suppr
			--inconclusive
			--suppress=missingIncludeSystem
			--suppress=missingInclude
			--quiet)
		message(STATUS "z3dsw: cppcheck -> ${Z3D_CPPCHECK}")
	else()
		message(
			WARNING "z3dsw: Z3D_ENABLE_CPPCHECK=ON but cppcheck was not found.")
	endif()
endif()
