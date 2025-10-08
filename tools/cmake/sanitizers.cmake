include_guard(GLOBAL)

# Enable AddressSanitizer (ASan) and UndefinedBehaviorSanitizer (UBSan).
# This function adds the necessary compiler and linker flags and ensures a Debug build type.
# It requires the GNU compiler.
function(sanitizers_enable)
    if(NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
        message(FATAL_ERROR "Sanitizers are only supported with GNU compiler.")
    endif()

    message(STATUS "Enabling ASan and UBSan")

    # Add sanitizer flags to C and CXX
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fsanitize=address,undefined -fno-omit-frame-pointer" CACHE STRING "C compiler flags" FORCE)
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fsanitize=address,undefined -fno-omit-frame-pointer" CACHE STRING "C++ compiler flags" FORCE)

    # Add linker flags
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -fsanitize=address,undefined" CACHE STRING "Executable linker flags" FORCE)
    set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -fsanitize=address,undefined" CACHE STRING "Shared library linker flags" FORCE)

    # Ensure debug build type for sanitizers
    if(NOT CMAKE_BUILD_TYPE MATCHES "Debug")
        set(CMAKE_BUILD_TYPE "Debug" CACHE STRING "Build type" FORCE)
    endif()
endfunction()
