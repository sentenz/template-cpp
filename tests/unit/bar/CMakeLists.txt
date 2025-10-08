gtest_add(
  WITH_CTEST TRUE WITH_MAIN TRUE
  TARGET ${PROJECT_NAME}-bar-test
  SOURCES
    bar_test.cpp
  LINK ${PROJECT_NAME}::bar
)
