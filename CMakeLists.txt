cmake_minimum_required(VERSION 3.28.3)

project(${META_PROJECT_NAME} LANGUAGES C CXX)

include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")

include(meta_policy)
meta_policy()

include(meta_compiler_cache)
meta_compiler_cache(ENABLE ${META_ENABLE_COMPILER_CACHE})

# Derive META_BUILD_TESTING from sub-flags
if(NOT DEFINED META_BUILD_TESTING_COLOCATE)
    set(META_BUILD_TESTING_COLOCATE OFF)
endif()
if(NOT DEFINED META_BUILD_TESTING_SEPARATE)
    set(META_BUILD_TESTING_SEPARATE OFF)
endif()
if(NOT DEFINED META_BUILD_TESTING_ONTARGET)
    set(META_BUILD_TESTING_ONTARGET OFF)
endif()

if(META_BUILD_TESTING_COLOCATE OR META_BUILD_TESTING_SEPARATE OR META_BUILD_TESTING_ONTARGET)
    set(META_BUILD_TESTING ON)
endif()

if(META_BUILD_TESTING)
    include(CTest)
    if(NOT DEFINED BUILD_TESTING)
        enable_testing()
    endif()

    include(meta_conan)
    meta_conan()

    if(NOT META_BUILD_TESTING_ONTARGET)
        include(meta_sanitizers)
        meta_sanitizers(ENABLE ${META_BUILD_TESTING})

        include(meta_coverage)
        meta_coverage(ENABLE ${META_BUILD_TESTING})
    endif()
endif()

add_subdirectory(src)

if(META_BUILD_TESTING_SEPARATE OR META_BUILD_TESTING_ONTARGET)
    add_subdirectory(tests)
endif()
