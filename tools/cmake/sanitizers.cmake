include_guard(GLOBAL)

# sanitizers_enable
#
# Enables AddressSanitizer and UndefinedBehaviorSanitizer for the current CMake project by
# appending the appropriate compiler and linker flags in an idempotent way and persisting them to
# the CMake cache.
#
# Usage
#   sanitizers_enable()
function(sanitizers_enable)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "Sanitizers are only supported with GNU compiler.")
    endif()

    set(_sanitize_compile_flags -fsanitize=address,undefined -fno-omit-frame-pointer)
    if(NOT DEFINED SANITIZERS_ENABLED)
        add_compile_options(${_sanitize_compile_flags})

        # Record that sanitizers have been enabled
        set(SANITIZERS_ENABLED TRUE CACHE INTERNAL "Sanitizers enabled")
    endif()

    set(_sanitize_link_flags -fsanitize=address,undefined)
    add_link_options(${_sanitize_link_flags})

    # Ensure debug build type for sanitizers
    if(NOT CMAKE_BUILD_TYPE)
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type")
    endif()
endfunction()
