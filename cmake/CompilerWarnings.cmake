# z3d_set_warnings(<target> [WARNINGS_AS_ERRORS]) Populates an INTERFACE target with a curated, portable warning set.
include_guard(GLOBAL)

function(z3d_set_warnings target)
    cmake_parse_arguments(ARG "WARNINGS_AS_ERRORS" "" "" ${ARGN})

    # Aggressive but broadly useful; supported by both GCC and Clang.
    set(gcc_clang_warnings
        -Wall
        -Wextra
        -Wpedantic
        -Wshadow
        -Wnon-virtual-dtor
        -Wold-style-cast
        -Wcast-align
        -Wunused
        -Woverloaded-virtual
        -Wconversion
        -Wsign-conversion
        -Wnull-dereference
        -Wdouble-promotion
        -Wimplicit-fallthrough
        -Wformat=2
        -Wextra-semi
    )

    # GCC-only diagnostics (Clang would reject these).
    set(gcc_only_warnings -Wmisleading-indentation -Wduplicated-cond -Wduplicated-branches -Wlogical-op -Wuseless-cast
                          -Wnull-dereference
    )

    # Clang-only diagnostics.
    set(clang_only_warnings -Wweak-vtables)

    set(msvc_warnings
        /W4
        /permissive-
        /w14242
        /w14254
        /w14263
        /w14265
        /w14287
        /we4289
        /w14296
        /w14311
        /w14545
        /w14546
        /w14547
        /w14549
        /w14555
        /w14619
        /w14640
        /w14826
        /w14905
        /w14906
        /w14928
    )
    if(ARG_WARNINGS_AS_ERRORS)
        list(APPEND msvc_warnings /WX)
    endif()

    target_compile_options(
        ${target}
        INTERFACE $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:
                  ${gcc_clang_warnings}>
                  $<$<CXX_COMPILER_ID:GNU>:${gcc_only_warnings}>
                  $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>>:${clang_only_warnings}>
                  $<$<CXX_COMPILER_ID:MSVC>:${msvc_warnings}>
    )

    if(ARG_WARNINGS_AS_ERRORS)
        target_compile_options(
            ${target}
            INTERFACE $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:-Werror>
        )
    endif()
endfunction()
