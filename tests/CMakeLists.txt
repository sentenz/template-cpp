if(META_BUILD_TESTING)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/tools/cmake")

  include(conan)
  conan_bootstrap()

  include(coverage)
  coverage_enable()

  include(sanitizers)
  sanitizers_enable()

  # Subdirectories
  add_subdirectory(unit)
endif()
