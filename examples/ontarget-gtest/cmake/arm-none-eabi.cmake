# STM32F407VG: ARM Cortex-M4F hard-float, GNU Arm Embedded toolchain.
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

set(ARM_TOOLCHAIN_PREFIX arm-none-eabi CACHE STRING "GNU Arm compiler prefix")
find_program(CMAKE_C_COMPILER NAMES ${ARM_TOOLCHAIN_PREFIX}-gcc REQUIRED)
find_program(CMAKE_CXX_COMPILER NAMES ${ARM_TOOLCHAIN_PREFIX}-g++ REQUIRED)
find_program(CMAKE_ASM_COMPILER NAMES ${ARM_TOOLCHAIN_PREFIX}-gcc REQUIRED)
find_program(CMAKE_AR NAMES ${ARM_TOOLCHAIN_PREFIX}-ar REQUIRED)
find_program(CMAKE_RANLIB NAMES ${ARM_TOOLCHAIN_PREFIX}-ranlib REQUIRED)
find_program(CMAKE_SIZE NAMES ${ARM_TOOLCHAIN_PREFIX}-size REQUIRED)

set(_cpu "-mcpu=cortex-m4 -mthumb -mfpu=fpv4-sp-d16 -mfloat-abi=hard")
set(CMAKE_C_FLAGS_INIT "${_cpu} -ffunction-sections -fdata-sections")
set(CMAKE_CXX_FLAGS_INIT "${_cpu} -ffunction-sections -fdata-sections -fno-exceptions -fno-rtti -fno-threadsafe-statics")
set(CMAKE_ASM_FLAGS_INIT "${_cpu}")
set(CMAKE_EXE_LINKER_FLAGS_INIT "${_cpu} -nostartfiles --specs=nano.specs --specs=nosys.specs -Wl,--gc-sections")
