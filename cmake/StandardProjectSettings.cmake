# Global compiler/toolchain defaults, plus the two INTERFACE targets that all first-party targets link against
# (z3d_project_warnings for warning flags, z3d_project_options for the language level, warnings and sanitizers).
include_guard(GLOBAL)

include(GNUInstallDirs)
include(CompilerWarnings)
include(Sanitizers)

# ---------------------------------------------------------------------------
# Sensible defaults
# ---------------------------------------------------------------------------
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# Always emit compile_commands.json for clang-tidy / clangd / IDEs.
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Single-config generators: pick Debug if the user did not choose one.
if(NOT CMAKE_BUILD_TYPE AND NOT CMAKE_CONFIGURATION_TYPES)
    set(CMAKE_BUILD_TYPE
        Debug
        CACHE STRING "Build type" FORCE
    )
    set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS Debug Release RelWithDebInfo MinSizeRel)
endif()

# Put every runtime/build artifact in predictable top-level folders.
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")

# Common places to find LLVM tools (clang-tidy, clang-format) when they are not on PATH - e.g. Homebrew keeps LLVM
# keg-only.
set(Z3D_LLVM_TOOL_HINTS
    /opt/homebrew/opt/llvm/bin /usr/local/opt/llvm/bin /usr/lib/llvm-19/bin /usr/lib/llvm-18/bin
    CACHE INTERNAL "Extra search paths for LLVM command-line tools"
)

# ---------------------------------------------------------------------------
# ccache / sccache
# ---------------------------------------------------------------------------
if(Z3D_ENABLE_CCACHE)
    find_program(Z3D_COMPILER_LAUNCHER NAMES ccache sccache)
    if(Z3D_COMPILER_LAUNCHER)
        set(CMAKE_CXX_COMPILER_LAUNCHER "${Z3D_COMPILER_LAUNCHER}")
        message(STATUS "z3dsw: compiler launcher -> ${Z3D_COMPILER_LAUNCHER}")
    else()
        message(STATUS "z3dsw: ccache/sccache requested but not found (install for faster rebuilds)")
    endif()
endif()

# ---------------------------------------------------------------------------
# Interprocedural optimization (LTO)
# ---------------------------------------------------------------------------
if(Z3D_ENABLE_IPO)
    include(CheckIPOSupported)
    check_ipo_supported(RESULT _z3d_ipo_ok OUTPUT _z3d_ipo_msg)
    if(_z3d_ipo_ok)
        set(CMAKE_INTERPROCEDURAL_OPTIMIZATION ON)
        message(STATUS "z3dsw: IPO/LTO enabled")
    else()
        message(WARNING "z3dsw: IPO requested but unsupported: ${_z3d_ipo_msg}")
    endif()
endif()

# ---------------------------------------------------------------------------
# INTERFACE targets
# ---------------------------------------------------------------------------
add_library(z3d_project_warnings INTERFACE)
add_library(z3d::warnings ALIAS z3d_project_warnings)

add_library(z3d_project_options INTERFACE)
add_library(z3d::options ALIAS z3d_project_options)

target_compile_features(z3d_project_options INTERFACE cxx_std_${Z3D_CXX_STANDARD})
target_link_libraries(z3d_project_options INTERFACE z3d_project_warnings)

if(Z3D_WARNINGS_AS_ERRORS)
    z3d_set_warnings(z3d_project_warnings WARNINGS_AS_ERRORS)
else()
    z3d_set_warnings(z3d_project_warnings)
endif()
z3d_enable_sanitizers(z3d_project_options)
