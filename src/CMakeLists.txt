add_library(znx znx/Vec3d.cc include/znx/Vec3d.hh)
add_library(znx::znx ALIAS znx)

target_include_directories(
    znx PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# Inherit language level, warnings, sanitizers, etc. Build-only: the helper interface targets are not part of the
# installed/exported package.
target_link_libraries(znx PRIVATE $<BUILD_INTERFACE:z3d_project_options>)

set_target_properties(
    znx
    PROPERTIES VERSION ${PROJECT_VERSION}
               SOVERSION ${PROJECT_VERSION_MAJOR}
               CXX_VISIBILITY_PRESET hidden
               VISIBILITY_INLINES_HIDDEN ON
               POSITION_INDEPENDENT_CODE ON
)

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
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
    install(
        EXPORT znxTargets
        FILE znxTargets.cmake
        NAMESPACE znx::
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx
    )

    configure_package_config_file(
        ${PROJECT_SOURCE_DIR}/cmake/znxConfig.cmake.in ${CMAKE_CURRENT_BINARY_DIR}/znxConfig.cmake
        INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx
    )
    write_basic_package_version_file(
        ${CMAKE_CURRENT_BINARY_DIR}/znxConfigVersion.cmake
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/znxConfig.cmake ${CMAKE_CURRENT_BINARY_DIR}/znxConfigVersion.cmake
            DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/znx
    )
endif()
