add_library(${PROJECT_NAME}-test INTERFACE)
target_link_libraries(${PROJECT_NAME}-test INTERFACE ${PROJECT_NAME}::includes)

if(NOT TARGET ${PROJECT_NAME}::test)
  add_library(${PROJECT_NAME}::test ALIAS ${PROJECT_NAME}-test)
endif()

# Subdirectories
add_subdirectory(foo)
add_subdirectory(bar)
