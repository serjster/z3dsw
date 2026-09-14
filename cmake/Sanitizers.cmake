# z3d_enable_sanitizers(<target>) Applies the sanitizers selected via Z3D_ENABLE_SANITIZER_* options to an INTERFACE
# target (so the flags propagate to everything that links it).
include_guard(GLOBAL)

function(z3d_enable_sanitizers target)
    set(sanitizers "")
    if(Z3D_ENABLE_SANITIZER_ADDRESS)
        list(APPEND sanitizers address)
    endif()
    if(Z3D_ENABLE_SANITIZER_UNDEFINED)
        list(APPEND sanitizers undefined)
    endif()
    if(Z3D_ENABLE_SANITIZER_THREAD)
        list(APPEND sanitizers thread)
    endif()
    if(Z3D_ENABLE_SANITIZER_MEMORY)
        list(APPEND sanitizers memory)
    endif()
    if(Z3D_ENABLE_SANITIZER_LEAK)
        list(APPEND sanitizers leak)
    endif()

    # Build a human readable summary for the top-level status block.
    if(sanitizers)
        string(REPLACE ";" "," Z3D_SANITIZER_SUMMARY "${sanitizers}")
    else()
        set(Z3D_SANITIZER_SUMMARY "off")
    endif()
    set(Z3D_SANITIZER_SUMMARY
        "${Z3D_SANITIZER_SUMMARY}"
        PARENT_SCOPE
    )
    set(Z3D_SANITIZER_SUMMARY
        "${Z3D_SANITIZER_SUMMARY}"
        CACHE INTERNAL "Enabled sanitizers (summary)"
    )

    if(NOT sanitizers)
        return()
    endif()

    # --- Conflict detection -------------------------------------------------
    set(_exclusive "")
    foreach(_s address thread memory)
        if(_s IN_LIST sanitizers)
            list(APPEND _exclusive ${_s})
        endif()
    endforeach()
    list(LENGTH _exclusive _exclusive_count)
    if(_exclusive_count GREATER 1)
        message(FATAL_ERROR "z3dsw: sanitizers address, thread and memory are mutually exclusive, "
                            "but the following were requested: ${_exclusive}"
        )
    endif()

    string(REPLACE ";" "," _sanitize_arg "${sanitizers}")

    if(MSVC)
        if(NOT _sanitize_arg STREQUAL "address")
            message(WARNING "z3dsw: MSVC only supports AddressSanitizer; ignoring other sanitizers "
                            "(requested: ${_sanitize_arg})"
            )
        endif()
        target_compile_options(${target} INTERFACE $<$<CXX_COMPILER_ID:MSVC>:/fsanitize=address>)
        message(STATUS "z3dsw: sanitizers -> address (MSVC)")
        return()
    endif()

    set(_flags -fsanitize=${_sanitize_arg} -fno-omit-frame-pointer -fno-sanitize-recover=all)

    target_compile_options(
        ${target}
        INTERFACE $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:${_flags}>
    )
    target_link_options(
        ${target} INTERFACE
        $<$<OR:$<CXX_COMPILER_ID:Clang>,$<CXX_COMPILER_ID:AppleClang>,$<CXX_COMPILER_ID:GNU>>:${_flags}>
    )

    message(STATUS "z3dsw: sanitizers -> ${_sanitize_arg}")
    message(STATUS "z3dsw: tip: set UBSAN_OPTIONS=print_stacktrace=1:halt_on_error=1 "
                   "and ASAN_OPTIONS=detect_leaks=1 at runtime for better reports"
    )
endfunction()
