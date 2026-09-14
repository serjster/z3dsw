add_library(
	znx
	SHARED
	include/znx/alias.hh
	include/znx/vec.hh
	include/znx/Vec3.hh
	znx/Vec3.cc)
add_library(znx::znx ALIAS znx)

# Generate the dllexport/visibility export header (modern CMake style). Consumers and the
# library itself define ZNX_STATIC_DEFINE for static builds, which makes ZNX_EXPORT expand
# to nothing.
include(GenerateExportHeader)
file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include/znx)
generate_export_header(
	znx
	BASE_NAME
	znx
	EXPORT_MACRO_NAME
	ZNX_EXPORT
	EXPORT_FILE_NAME
	${CMAKE_CURRENT_BINARY_DIR}/include/znx/export.hh
	STATIC_DEFINE
	ZNX_STATIC_DEFINE)

get_target_property(ZNX_LIBRARY_TYPE znx TYPE)
if(ZNX_LIBRARY_TYPE STREQUAL "STATIC_LIBRARY")
	target_compile_definitions(znx PUBLIC ZNX_STATIC_DEFINE)
endif()

target_include_directories(
	znx
	PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
		   $<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/include>
		   $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

# Inherit language level, warnings, sanitizers, etc. Build-only: the helper interface
# targets are not part of the installed/exported package.
target_link_libraries(znx PRIVATE $<BUILD_INTERFACE:z3d_project_options>)

set_target_properties(
	znx
	PROPERTIES VERSION ${PROJECT_VERSION}
			   SOVERSION ${PROJECT_VERSION_MAJOR}
			   CXX_VISIBILITY_PRESET hidden
			   VISIBILITY_INLINES_HIDDEN ON
			   POSITION_INDEPENDENT_CODE ON)

# ---------------------------------------------------------------------------
# Install / export (guarded by Z3D_INSTALL)
# ---------------------------------------------------------------------------
if(Z3D_INSTALL)
	include(CMakePackageConfigHelpers)

	install(
		TARGETS znx
		EXPORT znxTargets
		ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
		LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
		RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
	install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/
			DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/include/znx/export.hh
			DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/znx)
	install(
		EXPORT znxTargets
		FILE znxTargets.cmake
		NAMESPACE znx::
		DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx)

	configure_package_config_file(
		${PROJECT_SOURCE_DIR}/cmake/znxConfig.cmake.in
		${CMAKE_CURRENT_BINARY_DIR}/znxConfig.cmake
		INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx)
	write_basic_package_version_file(
		${CMAKE_CURRENT_BINARY_DIR}/znxConfigVersion.cmake
		VERSION ${PROJECT_VERSION}
		COMPATIBILITY SameMajorVersion)
	install(FILES ${CMAKE_CURRENT_BINARY_DIR}/znxConfig.cmake
				  ${CMAKE_CURRENT_BINARY_DIR}/znxConfigVersion.cmake
			DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx)
endif()
