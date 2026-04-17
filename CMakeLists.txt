cmake_minimum_required(VERSION 3.28.3)

project(${META_PROJECT_NAME} LANGUAGES C CXX)

include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")

include(meta_policy)
meta_policy()

include(meta_compiler_cache)
meta_compiler_cache(ENABLE ${META_ENABLE_COMPILER_CACHE})

# Testing mode variables:
#   META_BUILD_TESTING_COLOCATE - enable tests colocated with source in src/
#   META_BUILD_TESTING_SEPARATE - enable tests in the dedicated tests/unit/ tree
#   META_BUILD_TESTING_ONTARGET - enable on-target tests in tests/ontarget/ (cross-compiled, run via SEGGER J-Run)
option(META_BUILD_TESTING_COLOCATE "Enable colocated unit tests in src/" OFF)
option(META_BUILD_TESTING_SEPARATE "Enable unit tests in tests/unit/" OFF)
option(META_BUILD_TESTING_ONTARGET "Enable on-target tests in tests/ontarget/" OFF)

if(META_BUILD_TESTING_COLOCATE OR META_BUILD_TESTING_SEPARATE OR META_BUILD_TESTING_ONTARGET)
    include(CTest)
    if(NOT DEFINED BUILD_TESTING)
        enable_testing()
    endif()

    include(meta_conan)
    meta_conan()
endif()

if(META_BUILD_TESTING_COLOCATE OR META_BUILD_TESTING_SEPARATE)
    include(meta_sanitizers)
    meta_sanitizers(ENABLE ON)

    include(meta_coverage)
    meta_coverage(ENABLE ON)
endif()

add_subdirectory(src)

if(META_BUILD_TESTING_SEPARATE OR META_BUILD_TESTING_ONTARGET)
    add_subdirectory(tests)
endif()
