include_guard(GLOBAL)
include(CMakeParseArguments)

# Compile only the explicitly listed, application-owned C translation units.
# The caller keeps NDK glue in its normal target source list and links these
# generated objects with the NDK toolchain. No C source reaches the assembler.
function(ick_android_objects output)
  cmake_parse_arguments(OWNED "" "NAME;STANDARD" "SOURCES;INCLUDES;OPTIONS;DEFINITIONS" ${ARGN})
  if(OWNED_UNPARSED_ARGUMENTS OR NOT OWNED_NAME OR NOT OWNED_SOURCES)
    message(FATAL_ERROR "ick_android_objects needs NAME and SOURCES; unknown arguments: ${OWNED_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT CMAKE_SYSTEM_NAME STREQUAL "Android")
    message(FATAL_ERROR "OwnedC.cmake requires the consumer's Android NDK CMake toolchain")
  endif()
  if(CMAKE_CONFIGURATION_TYPES)
    message(FATAL_ERROR "OwnedC.cmake requires a single-configuration Android build")
  endif()
  foreach(required ICK_COMPILER ICK_HEADER_TARGET CMAKE_SYSROOT CMAKE_C_COMPILER ANDROID_PLATFORM_LEVEL)
    if(NOT DEFINED ${required} OR "${${required}}" STREQUAL "")
      message(FATAL_ERROR "OwnedC.cmake requires ${required}")
    endif()
  endforeach()
  if(NOT IS_ABSOLUTE "${ICK_COMPILER}" OR NOT EXISTS "${ICK_COMPILER}")
    message(FATAL_ERROR "ICK_COMPILER must name the installed, qualified ICK executable")
  endif()
  if(NOT EXISTS "${CMAKE_SYSROOT}/usr/include/${ICK_HEADER_TARGET}")
    message(FATAL_ERROR "ICK_HEADER_TARGET is missing from the selected NDK sysroot")
  endif()
  if(NOT ANDROID_PLATFORM_LEVEL MATCHES "^[0-9]+$")
    message(FATAL_ERROR "ANDROID_PLATFORM_LEVEL must be the numeric NDK API floor")
  endif()
  if(NOT OWNED_STANDARD)
    if(CMAKE_C_STANDARD)
      set(OWNED_STANDARD "${CMAKE_C_STANDARD}")
    else()
      set(OWNED_STANDARD 11)
    endif()
  endif()
  separate_arguments(ick_support NATIVE_COMMAND "${ICK_COMPILER_OPTIONS}")
  separate_arguments(ick_target NATIVE_COMMAND "${ICK_TARGET_FLAGS}")
  if(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
    set(expected_target arm-linux-gnueabi)
    set(expected_headers arm-linux-androideabi)
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    set(expected_target aarch64-linux-gnu)
    set(expected_headers aarch64-linux-android)
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(expected_target x86_64-linux-gnu)
    set(expected_headers x86_64-linux-android)
  else()
    message(FATAL_ERROR "OwnedC.cmake has no qualified ICK target for ${CMAKE_ANDROID_ARCH_ABI}")
  endif()
  execute_process(COMMAND "${ICK_COMPILER}" ${ick_support} -dumpmachine
    OUTPUT_VARIABLE actual_target OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE target_result)
  if(NOT target_result EQUAL 0 OR NOT actual_target STREQUAL expected_target OR NOT ICK_HEADER_TARGET STREQUAL expected_headers)
    message(FATAL_ERROR "ICK target/header mismatch: ${actual_target}, ${ICK_HEADER_TARGET}; expected ${expected_target}, ${expected_headers}")
  endif()
  separate_arguments(c_flags NATIVE_COMMAND "${CMAKE_C_FLAGS}")
  string(TOUPPER "${CMAKE_BUILD_TYPE}" build_type)
  separate_arguments(configuration_flags NATIVE_COMMAND "${CMAKE_C_FLAGS_${build_type}}")
  get_directory_property(directory_options COMPILE_OPTIONS)
  get_directory_property(directory_definitions COMPILE_DEFINITIONS)
  get_directory_property(directory_includes INCLUDE_DIRECTORIES)
  set(assembler_target)
  if(CMAKE_C_COMPILER_TARGET)
    list(APPEND assembler_target "--target=${CMAKE_C_COMPILER_TARGET}")
  endif()
  set(objects)
  foreach(source IN LISTS OWNED_SOURCES)
    if(NOT source MATCHES "\\.c$")
      message(FATAL_ERROR "OwnedC.cmake only accepts C source: ${source}")
    endif()
    get_filename_component(source_absolute "${source}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    get_filename_component(source_name "${source}" NAME)
    string(SHA256 source_key "${source_absolute}")
    string(SUBSTRING "${source_key}" 0 12 source_key)
    set(object_directory "${CMAKE_CURRENT_BINARY_DIR}/ick/${OWNED_NAME}")
    set(object "${object_directory}/${source_name}-${source_key}.o")
    set(assembly "${object}.s")
    set(dependencies "${object}.d")
    foreach(property COMPILE_OPTIONS COMPILE_FLAGS COMPILE_DEFINITIONS INCLUDE_DIRECTORIES)
      get_source_file_property(source_${property} "${source_absolute}" ${property})
      if(source_${property} STREQUAL "NOTFOUND")
        set(source_${property})
      endif()
    endforeach()
    separate_arguments(source_flags NATIVE_COMMAND "${source_COMPILE_FLAGS}")
    set(includes)
    foreach(directory IN LISTS directory_includes OWNED_INCLUDES source_INCLUDE_DIRECTORIES)
      get_filename_component(include_absolute "${directory}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
      list(APPEND includes "-I${include_absolute}")
    endforeach()
    set(definitions)
    foreach(definition IN LISTS directory_definitions OWNED_DEFINITIONS source_COMPILE_DEFINITIONS)
      list(APPEND definitions "-D${definition}")
    endforeach()
    # Preserve the complete inherited NDK flags, including Fortify, stack
    # protection, warnings and build-type optimization. An unsupported flag or
    # header is a compiler failure; do not erase it or retry with stock C.
    add_custom_command(
      OUTPUT "${object}"
      BYPRODUCTS "${assembly}" "${dependencies}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${object_directory}"
      COMMAND "${ICK_COMPILER}" ${ick_support} ${ick_target}
        ${c_flags} ${configuration_flags} ${directory_options}
        ${OWNED_OPTIONS} ${source_COMPILE_OPTIONS} ${source_flags}
        "--sysroot=${CMAKE_SYSROOT}"
        -isystem "${CMAKE_SYSROOT}/usr/include"
        -isystem "${CMAKE_SYSROOT}/usr/include/${ICK_HEADER_TARGET}"
        -D__ANDROID__ "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}"
        -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD "-std=c${OWNED_STANDARD}" -fPIC
        -gno-variable-location-views
        ${includes} ${definitions}
        -MMD -MT "${object}" -MF "${dependencies}"
        -S "${source_absolute}" -o "${assembly}"
      COMMAND "${CMAKE_C_COMPILER}" ${assembler_target} ${ick_target}
        "--sysroot=${CMAKE_SYSROOT}" -c "${assembly}" -o "${object}"
      DEPENDS "${source_absolute}" "${ICK_COMPILER}"
      DEPFILE "${dependencies}"
      COMMAND_EXPAND_LISTS
      VERBATIM
      COMMENT "ICK C and NDK assembly: ${source_name}"
    )
    set_source_files_properties("${object}" PROPERTIES EXTERNAL_OBJECT TRUE GENERATED TRUE)
    list(APPEND objects "${object}")
  endforeach()
  set(${output} "${objects}" PARENT_SCOPE)
endfunction()
