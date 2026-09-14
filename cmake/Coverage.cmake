# Code-coverage integration (gcovr).
#
# z3d_enable_coverage(<target>)  Instrument an INTERFACE target with coverage
# flags. z3d_prepare_coverage()         Locate gcovr; add the `coverage` build
# target and a CTest fixture that emits the report after the tests.
#
# Controlled by Z3D_ENABLE_COVERAGE. In a coverage build, simply running the
# tests (ctest, or the `test` target) leaves a fresh report at:
# build/<preset>/coverage/index.html    (HTML, annotated per line)
# build/<preset>/coverage/coverage.txt  (text) and prints a summary to the
# console. `cmake --build --target coverage` regenerates it from the last test
# run.
include_guard(GLOBAL)

function(z3d_enable_coverage target)
	if(NOT Z3D_ENABLE_COVERAGE)
		return()
	endif()
	if(MSVC)
		message(
			WARNING
				"z3dsw: Z3D_ENABLE_COVERAGE is not supported with MSVC; ignoring"
		)
		return()
	endif()

	set(_flag
		$<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:--coverage>
	)
	target_compile_options(${target} INTERFACE ${_flag})
	target_link_options(${target} INTERFACE ${_flag})
	message(STATUS "z3dsw: coverage instrumentation enabled (--coverage)")
endfunction()

function(z3d_prepare_coverage)
	if(NOT Z3D_ENABLE_COVERAGE)
		return()
	endif()

	find_program(
		Z3D_GCOVR
		NAMES gcovr
		HINTS "${PROJECT_SOURCE_DIR}/.venv/bin")
	if(NOT Z3D_GCOVR)
		message(
			WARNING
				"z3dsw: Z3D_ENABLE_COVERAGE=ON but gcovr was not found; coverage reports disabled. "
				"Run scripts/bootstrap.sh or 'pip install gcovr'.")
		return()
	endif()

	set(_report_dir "${CMAKE_BINARY_DIR}/coverage-report")
	file(MAKE_DIRECTORY "${_report_dir}")

	# Only the library sources make up the report; tests and the demo app are
	# excluded.
	set(_gcovr_args
		--root
		"${PROJECT_SOURCE_DIR}"
		--filter
		"${PROJECT_SOURCE_DIR}/src/"
		--exclude
		"${PROJECT_SOURCE_DIR}/tests/"
		--gcov-ignore-parse-errors
		--print-summary
		--txt
		"${_report_dir}/coverage.txt"
		--html-details
		"${_report_dir}/index.html"
		# Positional search path: restrict gcovr to this build tree so sibling
		# builds (e.g. build/coverage) can't contribute stale .gcda data.
		"${CMAKE_BINARY_DIR}")

	# Manual target (uses data from the last test run).
	add_custom_target(
		coverage
		COMMAND "${Z3D_GCOVR}" ${_gcovr_args}
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
		COMMENT "z3dsw: coverage report -> ${_report_dir}/index.html"
		VERBATIM)

	# CTest step: registered as the cleanup of a fixture that every test
	# requires, so it runs last and the report is always regenerated as part of
	# the test run.
	add_test(NAME coverage-report COMMAND "${Z3D_GCOVR}" ${_gcovr_args})
	set_tests_properties(
		coverage-report PROPERTIES FIXTURES_CLEANUP z3d_coverage
								   WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")

	message(
		STATUS
			"z3dsw: coverage report -> ${_report_dir}/index.html (gcovr: ${Z3D_GCOVR})"
	)
endfunction()
