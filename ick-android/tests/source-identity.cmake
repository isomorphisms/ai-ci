cmake_minimum_required(VERSION 3.22)
include("${CMAKE_CURRENT_LIST_DIR}/../OwnedC.cmake")

if(DEFINED OUTSIDE_ROOT)
  _ick_object_identity("/checkout/source-other/scene.c" canonical key
    "/checkout/source|@source@")
  message(FATAL_ERROR "Sibling prefix was incorrectly admitted")
endif()

set(expected "@source@/nested/scene.c")
string(SHA256 expected_key "${expected}")
string(SUBSTRING "${expected_key}" 0 12 expected_key)
_ick_object_identity("/first checkout/source/nested/scene.c" first first_key
  "/first checkout|@checkout@" "/first checkout/source|@source@")
_ick_object_identity("/second ' checkout/source/nested/scene.c" second second_key
  "/second ' checkout/source|@source@" "/second ' checkout|@checkout@")
if(NOT first STREQUAL expected OR NOT second STREQUAL expected OR
    NOT first_key STREQUAL expected_key OR NOT second_key STREQUAL expected_key)
  message(FATAL_ERROR "Relocated source names or reordered roots changed object identity")
endif()
_ick_object_identity("/first checkout/source/other/scene.c" other other_key
  "/first checkout/source|@source@")
if(other_key STREQUAL first_key)
  message(FATAL_ERROR "Distinct relative sources with the same basename collided")
endif()

# Preserve the actual former defect as a deliberately wrong naming control.
string(SHA256 wrong_first "/first checkout/source/nested/scene.c")
string(SHA256 wrong_second "/second ' checkout/source/nested/scene.c")
string(SUBSTRING "${wrong_first}" 0 12 wrong_first)
string(SUBSTRING "${wrong_second}" 0 12 wrong_second)
if(wrong_first STREQUAL wrong_second OR wrong_first STREQUAL expected_key)
  message(FATAL_ERROR "Absolute-path naming counterexample did not execute")
endif()
execute_process(COMMAND "${CMAKE_COMMAND}" -DOUTSIDE_ROOT=ON -P "${CMAKE_CURRENT_LIST_FILE}"
  RESULT_VARIABLE status OUTPUT_VARIABLE output ERROR_VARIABLE error)
if(status EQUAL 0 OR NOT "${output}${error}" MATCHES "outside declared material roots")
  message(FATAL_ERROR "Sibling-prefix source did not fail at its intended boundary: ${output}${error}")
endif()
message(STATUS "ICK source identity: relocation, root order, distinct sources and outside-root refusal PASS")
