cmake_minimum_required(VERSION 3.28.3)

project(${META_PROJECT_NAME} LANGUAGES C CXX)

include(GNUInstallDirs)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")

include(meta_policy)
meta_policy()

include(meta_compiler_cache)
meta_compiler_cache(ENABLE ${META_ENABLE_COMPILER_CACHE})

if(META_BUILD_TESTING)
    include(CTest)
    if(NOT DEFINED BUILD_TESTING)
        enable_testing()
    endif()

    include(meta_conan)
    meta_conan()

    include(meta_sanitizers)
    meta_sanitizers(ENABLE ${META_BUILD_TESTING})

    include(meta_coverage)
    meta_coverage(ENABLE ${META_BUILD_TESTING})
endif()

add_subdirectory(src)
