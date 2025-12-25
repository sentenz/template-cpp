meta_gtest(
  WITH_DDT
  TARGET ${PROJECT_NAME}-test
  SOURCES
    foo_test.cpp
  LINK
    ${PROJECT_NAME}::foo
)
