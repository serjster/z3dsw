# z3d_add_format_targets() Creates: format        - reformat C/C++
# (clang-format) and CMake (cmake-format) in place format-check  - non-mutating
# CI check; fails if anything is mis-formatted cmake-lint    - lint CMake files
# (if cmake-lint is available) File lists are collected with CONFIGURE_DEPENDS
# so newly added files are picked up without a manual re-configure. Only
# first-party directories are scanned, so build/ trees are never touched.
include_guard(GLOBAL)

function(z3d_add_format_targets)
	find_program(
		Z3D_CLANG_FORMAT
		NAMES clang-format clang-format-19 clang-format-18
		HINTS ${Z3D_LLVM_TOOL_HINTS} "${PROJECT_SOURCE_DIR}/.venv/bin")
	find_program(
		Z3D_CMAKE_FORMAT
		NAMES cmake-format
		HINTS "${PROJECT_SOURCE_DIR}/.venv/bin")
	find_program(
		Z3D_CMAKE_LINT
		NAMES cmake-lint
		HINTS "${PROJECT_SOURCE_DIR}/.venv/bin")

	if(NOT Z3D_CLANG_FORMAT AND NOT Z3D_CMAKE_FORMAT)
		message(
			WARNING
				"z3dsw: neither clang-format nor cmake-format found; "
				"format targets disabled. Install clang-format (brew install llvm) "
				"and cmake-format (pip install cmake-format).")
		return()
	endif()

	set(_scan_dirs apps src tests include docs)
	set(_cxx_files "")
	set(_cmake_files "")

	foreach(_dir IN LISTS _scan_dirs)
		if(NOT IS_DIRECTORY "${PROJECT_SOURCE_DIR}/${_dir}")
			continue()
		endif()
		file(GLOB_RECURSE _found CONFIGURE_DEPENDS
			 "${PROJECT_SOURCE_DIR}/${_dir}/*")
		foreach(_f IN LISTS _found)
			if(_f MATCHES "\\.(c|cc|cpp|cxx|c\\+\\+|h|hh|hpp|hxx|h\\+\\+)$")
				list(APPEND _cxx_files "${_f}")
			elseif(_f MATCHES "(^|/)CMakeLists\\.txt$" OR _f MATCHES
														  "\\.cmake$")
				list(APPEND _cmake_files "${_f}")
			endif()
		endforeach()
	endforeach()

	# Root CMake files.
	if(EXISTS "${PROJECT_SOURCE_DIR}/CMakeLists.txt")
		list(APPEND _cmake_files "${PROJECT_SOURCE_DIR}/CMakeLists.txt")
	endif()
	file(GLOB _root_modules CONFIGURE_DEPENDS
		 "${PROJECT_SOURCE_DIR}/cmake/*.cmake")
	list(APPEND _cmake_files ${_root_modules})

	list(REMOVE_DUPLICATES _cxx_files)
	list(REMOVE_DUPLICATES _cmake_files)
	list(SORT _cxx_files)
	list(SORT _cmake_files)

	# ---- format (in place) -------------------------------------------------
	set(_format_cmds "")
	set(_check_cmds "")
	if(Z3D_CLANG_FORMAT AND _cxx_files)
		list(
			APPEND
			_format_cmds
			COMMAND
			"${Z3D_CLANG_FORMAT}"
			-i
			--style=file
			${_cxx_files})
		list(
			APPEND
			_check_cmds
			COMMAND
			"${Z3D_CLANG_FORMAT}"
			--dry-run
			-Werror
			--style=file
			${_cxx_files})
	endif()
	if(Z3D_CMAKE_FORMAT AND _cmake_files)
		list(APPEND _format_cmds COMMAND "${Z3D_CMAKE_FORMAT}" -i
			 ${_cmake_files})
		list(APPEND _check_cmds COMMAND "${Z3D_CMAKE_FORMAT}" --check
			 ${_cmake_files})
	endif()

	if(_format_cmds)
		add_custom_target(
			format
			${_format_cmds}
			WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
			COMMENT "z3dsw: reformatting sources (clang-format + cmake-format)"
			VERBATIM)
	endif()

	if(_check_cmds)
		add_custom_target(
			format-check
			${_check_cmds}
			WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
			COMMENT "z3dsw: checking formatting (fails on any diff)"
			VERBATIM)
	endif()

	if(Z3D_CMAKE_LINT AND _cmake_files)
		add_custom_target(
			cmake-lint
			COMMAND "${Z3D_CMAKE_LINT}" ${_cmake_files}
			WORKING_DIRECTORY "${PROJECT_SOURCE_DIR}"
			COMMENT "z3dsw: linting CMake files"
			VERBATIM)
	endif()

	message(
		STATUS
			"z3dsw: format targets enabled "
			"(clang-format=${Z3D_CLANG_FORMAT}, cmake-format=${Z3D_CMAKE_FORMAT})"
	)
endfunction()
