gtest_add(
  WITH_CTEST TRUE WITH_MAIN TRUE
  TARGET ${PROJECT_NAME}-foo-test
  SOURCES
    foo_test.cpp
  LINK ${PROJECT_NAME}::foo
)
