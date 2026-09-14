cmake_minimum_required(VERSION 3.25)

project(
    z3dsw
    VERSION 0.1.0
    DESCRIPTION "znx-sw-3d - an educational software 3d rendering engine"
    HOMEPAGE_URL "https://example.com/z3dsw"
    LANGUAGES CXX
)

# "include" path for CMake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

# Options
include(z3dOptions)
include(PreventInSourceBuilds)
include(StandardProjectSettings)

# Static analyzers hook
include(StaticAnalyzers)

# "format" build target
if(Z3D_ENABLE_FORMAT)
    include(Formatting)
    z3d_add_format_targets()
endif()

add_subdirectory(src)
add_subdirectory(apps/z3dsw)

if(Z3D_ENABLE_TESTING)
    enable_testing()
    add_subdirectory(tests)
endif()

if(Z3D_ENABLE_DOCS)
    include(Documentation)
endif()

# ---------------------------------------------------------------------------
# Configuration summary
# ---------------------------------------------------------------------------
message(STATUS "---------------- z3dsw configuration ----------------")
message(STATUS "  version ............ ${PROJECT_VERSION}")
message(STATUS "  C++ standard ....... ${Z3D_CXX_STANDARD}")
message(STATUS "  build type ......... ${CMAKE_BUILD_TYPE}")
message(STATUS "  testing ............ ${Z3D_ENABLE_TESTING}")
message(STATUS "  docs ............... ${Z3D_ENABLE_DOCS}")
message(STATUS "  format targets ..... ${Z3D_ENABLE_FORMAT}")
message(STATUS "  clang-tidy ......... ${Z3D_ENABLE_CLANG_TIDY}")
message(STATUS "  cppcheck ........... ${Z3D_ENABLE_CPPCHECK}")
message(STATUS "  warnings-as-errors . ${Z3D_WARNINGS_AS_ERRORS}")
message(STATUS "  sanitizers ......... ${Z3D_SANITIZER_SUMMARY}")
message(STATUS "  IPO/LTO ............ ${Z3D_ENABLE_IPO}")
message(STATUS "----------------------------------------------------")
