meta_gtest(
  TARGET ${PROJECT_NAME}
  SOURCES
    bar_test.cpp
  LINK
    ${PROJECT_NAME}::bar
)
