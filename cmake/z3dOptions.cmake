# Centralized, self-documenting list of every user-facing option. Defaults are derived from PROJECT_IS_TOP_LEVEL so the
# project behaves nicely both standalone and when vendored via add_subdirectory()/FetchContent.
include_guard(GLOBAL)

if(NOT DEFINED PROJECT_IS_TOP_LEVEL)
    set(PROJECT_IS_TOP_LEVEL OFF)
endif()

# --- Quality gates -----------------------------------------------------------
option(Z3D_ENABLE_FORMAT "Add 'format' and 'format-check' targets" ${PROJECT_IS_TOP_LEVEL})
option(Z3D_ENABLE_CLANG_TIDY "Run clang-tidy as part of the build" OFF)
option(Z3D_ENABLE_CPPCHECK "Run cppcheck as part of the build" OFF)
option(Z3D_WARNINGS_AS_ERRORS "Treat compiler (and clang-tidy) warnings as errors" OFF)

# --- Testing / docs ----------------------------------------------------------
option(Z3D_ENABLE_TESTING "Build unit tests and register them with CTest" ${PROJECT_IS_TOP_LEVEL})
option(Z3D_ENABLE_DOCS "Add Doxygen/Sphinx documentation targets" ${PROJECT_IS_TOP_LEVEL})

# --- Sanitizers --------------------------------------------------------------
option(Z3D_ENABLE_SANITIZER_ADDRESS "Enable AddressSanitizer (ASan)" OFF)
option(Z3D_ENABLE_SANITIZER_UNDEFINED "Enable UndefinedBehaviorSanitizer (UBSan)" OFF)
option(Z3D_ENABLE_SANITIZER_THREAD "Enable ThreadSanitizer (TSan)" OFF)
option(Z3D_ENABLE_SANITIZER_MEMORY "Enable MemorySanitizer (MSan; needs fully instrumented deps)" OFF)
option(Z3D_ENABLE_SANITIZER_LEAK "Enable LeakSanitizer (LSan; standalone, Linux/macOS)" OFF)

# --- Build acceleration / packaging -----------------------------------------
option(Z3D_ENABLE_CCACHE "Use ccache/sccache as a compiler launcher when available" ON)
option(Z3D_ENABLE_IPO "Enable interprocedural optimization (LTO)" OFF)
option(Z3D_INSTALL "Generate install and package-export rules" ${PROJECT_IS_TOP_LEVEL})

# --- Language level ----------------------------------------------------------
set(Z3D_CXX_STANDARD
    23
    CACHE STRING "C++ standard to compile with (20, 23, 26)"
)
set_property(CACHE Z3D_CXX_STANDARD PROPERTY STRINGS 20 23 26)

set(_z3d_supported_std 20 23 26)
if(NOT Z3D_CXX_STANDARD IN_LIST _z3d_supported_std)
    message(FATAL_ERROR "Z3D_CXX_STANDARD must be one of 20, 23, 26 (got '${Z3D_CXX_STANDARD}')")
endif()
unset(_z3d_supported_std)
