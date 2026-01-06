include(meta_gtest)

meta_gtest(
  WITH_CTEST
  WITH_MAIN
  TARGET ${PROJECT_NAME}
)

add_subdirectory(foo)
add_subdirectory(bar)
