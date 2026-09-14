# Documentation targets. docs-doxygen : generate HTML + XML (XML feeds Sphinx/Breathe)
# docs-lint    : run Doxygen with WARN_AS_ERROR=YES -> fails on doc warnings docs-sphinx :
# build the Sphinx site (needs docs/requirements.txt installed) docs         : build the
# "best available" documentation All targets degrade gracefully when the underlying tool
# is not installed.
include_guard(GLOBAL)

set(_z3d_docs_src "${CMAKE_CURRENT_SOURCE_DIR}/docs")
set(_z3d_docs_bin "${CMAKE_CURRENT_BINARY_DIR}/docs")
set(_z3d_doxy_dir "${_z3d_docs_bin}/doxygen")

# Doxygen INPUT: headers, sources and the docs markdown.
set(_z3d_doxy_input "")
foreach(_p "${CMAKE_CURRENT_SOURCE_DIR}/src" "${CMAKE_CURRENT_SOURCE_DIR}/apps"
		   "${_z3d_docs_src}")
	if(IS_DIRECTORY "${_p}")
		list(APPEND _z3d_doxy_input "${_p}")
	endif()
endforeach()
string(REPLACE ";" " " Z3D_DOXYGEN_INPUT "${_z3d_doxy_input}")

find_package(Doxygen QUIET OPTIONAL_COMPONENTS dot)

if(DOXYGEN_FOUND)
	# --- generation Doxyfile (HTML + XML, warnings non-fatal) ---------------
	set(Z3D_DOXYGEN_OUTPUT_DIR "${_z3d_doxy_dir}")
	set(Z3D_DOXYGEN_GENERATE_HTML "YES")
	set(Z3D_DOXYGEN_GENERATE_XML "YES")
	set(Z3D_DOXYGEN_WARN_AS_ERROR "NO")
	set(Z3D_DOXYGEN_WARN_LOGFILE "")
	configure_file("${_z3d_docs_src}/Doxyfile.in" "${_z3d_docs_bin}/Doxyfile" @ONLY)

	add_custom_target(
		docs-doxygen
		COMMAND "${DOXYGEN_EXECUTABLE}" "${_z3d_docs_bin}/Doxyfile"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT "z3dsw: generating Doxygen docs -> ${_z3d_doxy_dir}/html"
		VERBATIM)

	# --- lint Doxyfile (parse only, fail on any warning) --------------------
	set(Z3D_DOXYGEN_OUTPUT_DIR "${_z3d_docs_bin}/doxygen-lint")
	set(Z3D_DOXYGEN_GENERATE_HTML "NO")
	set(Z3D_DOXYGEN_GENERATE_XML "NO")
	set(Z3D_DOXYGEN_WARN_AS_ERROR "YES")
	set(Z3D_DOXYGEN_WARN_LOGFILE "")
	configure_file("${_z3d_docs_src}/Doxyfile.in" "${_z3d_docs_bin}/Doxyfile.lint" @ONLY)

	add_custom_target(
		docs-lint
		COMMAND "${DOXYGEN_EXECUTABLE}" "${_z3d_docs_bin}/Doxyfile.lint"
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT "z3dsw: linting documentation comments (Doxygen, warnings are errors)"
		VERBATIM)

	set(_z3d_docs_default docs-doxygen)
else()
	message(WARNING "z3dsw: Doxygen not found; docs-doxygen/docs-lint disabled. "
					"Install with 'brew install doxygen' or 'apt install doxygen'.")
endif()

# --- Sphinx -----------------------------------------------------------------
find_program(
	Z3D_SPHINX_BUILD
	NAMES sphinx-build
	HINTS "${CMAKE_CURRENT_SOURCE_DIR}/.venv-docs/bin"
		  "${CMAKE_CURRENT_SOURCE_DIR}/.venv/bin")
if(Z3D_SPHINX_BUILD AND DOXYGEN_FOUND)
	set(_z3d_sphinx_bin "${_z3d_docs_bin}/sphinx")
	add_custom_target(
		docs-sphinx
		COMMAND "${CMAKE_COMMAND}" -E env DOXYGEN_XML_DIR=${_z3d_doxy_dir}/xml
				"${Z3D_SPHINX_BUILD}" -b html "${_z3d_docs_src}" "${_z3d_sphinx_bin}/html"
		DEPENDS docs-doxygen
		WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
		COMMENT "z3dsw: building Sphinx site -> ${_z3d_sphinx_bin}/html"
		VERBATIM)
	set(_z3d_docs_default docs-sphinx)
elseif(NOT Z3D_SPHINX_BUILD)
	message(STATUS "z3dsw: sphinx-build not found; docs-sphinx disabled. "
				   "Install docs/requirements.txt into a venv to enable it.")
endif()

# --- aggregate target -------------------------------------------------------
if(DEFINED _z3d_docs_default)
	add_custom_target(
		docs
		COMMAND "${CMAKE_COMMAND}" -E echo "Built '${_z3d_docs_default}'."
		DEPENDS ${_z3d_docs_default}
		COMMENT "z3dsw: building documentation (${_z3d_docs_default})"
		VERBATIM)
endif()
