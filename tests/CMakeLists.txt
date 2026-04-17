if(META_BUILD_TESTING_SEPARATE)
    add_subdirectory(unit)
endif()

if(META_BUILD_TESTING_ONTARGET)
    add_subdirectory(ontarget)
endif()
