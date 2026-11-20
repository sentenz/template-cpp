include(FetchContent)
set(SEGGER_RTT_ROOT "" CACHE PATH "Local SEGGER RTT source checkout (optional)")
# Pinned official RTT revision for reproducible builds.
set(SEGGER_RTT_GIT_TAG "9106eaa39babe53e00994d7828c1afb29390cdc1" CACHE STRING "SEGGER RTT Git revision")

if(SEGGER_RTT_ROOT)
  set(_rtt_source "${SEGGER_RTT_ROOT}")
else()
  FetchContent_Declare(segger_rtt_upstream
    GIT_REPOSITORY https://github.com/SEGGERMicro/RTT.git
    GIT_TAG ${SEGGER_RTT_GIT_TAG}
  )
  FetchContent_MakeAvailable(segger_rtt_upstream)
  set(_rtt_source "${segger_rtt_upstream_SOURCE_DIR}")
endif()

if(NOT EXISTS "${_rtt_source}/RTT/SEGGER_RTT.c")
  message(FATAL_ERROR "SEGGER_RTT_ROOT must contain RTT/SEGGER_RTT.c")
endif()
add_library(segger_rtt STATIC
  "${_rtt_source}/RTT/SEGGER_RTT.c"
  "${_rtt_source}/RTT/SEGGER_RTT_printf.c"
)
target_include_directories(segger_rtt PUBLIC
  "${_rtt_source}/RTT"
  "${_rtt_source}/Config"
)
