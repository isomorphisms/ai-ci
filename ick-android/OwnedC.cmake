include_guard(GLOBAL)
include(CMakeParseArguments)

function(_ick_record_hash record index output)
  file(STRINGS "${record}" record_lines)
  list(LENGTH record_lines record_length)
  if(record_length LESS_EQUAL index)
    message(FATAL_ERROR "ICK material record ${record} has no line ${index}")
  endif()
  list(GET record_lines ${index} record_line)
  if(NOT record_line MATCHES "^([0-9a-f]+)[ \t]+.+$")
    message(FATAL_ERROR "ICK material record ${record} has an invalid SHA-256 line: ${record_line}")
  endif()
  set(record_hash "${CMAKE_MATCH_1}")
  string(LENGTH "${record_hash}" record_hash_length)
  if(NOT record_hash_length EQUAL 64)
    message(FATAL_ERROR "ICK material record ${record} has a non-SHA-256 digest: ${record_hash}")
  endif()
  set(${output} "${record_hash}" PARENT_SCOPE)
endfunction()

function(_ick_canonicalize input output)
  set(canonical "${input}")
  foreach(mapping IN LISTS ARGN)
    string(REPLACE "|" ";" mapping_parts "${mapping}")
    list(GET mapping_parts 0 mapping_root)
    list(GET mapping_parts 1 mapping_name)
    if(NOT "${mapping_root}" STREQUAL "")
      string(REPLACE "${mapping_root}" "${mapping_name}" canonical "${canonical}")
    endif()
  endforeach()
  set(${output} "${canonical}" PARENT_SCOPE)
endfunction()

function(_ick_append_value variable key value)
  if("${key}" MATCHES "[\t\r\n]" OR "${value}" MATCHES "[\t\r\n]")
    message(FATAL_ERROR "ICK material values cannot contain tabs or newlines: ${key}")
  endif()
  set(content "${${variable}}value\t${key}\t${value}\n")
  set(${variable} "${content}" PARENT_SCOPE)
endfunction()

function(_ick_append_file variable key canonical path guard expected)
  if(NOT IS_ABSOLUTE "${path}" OR NOT EXISTS "${path}")
    message(FATAL_ERROR "ICK material ${key} must name an existing absolute path: ${path}")
  endif()
  file(SHA256 "${path}" observed)
  if(NOT "${expected}" STREQUAL "" AND NOT observed STREQUAL expected)
    message(FATAL_ERROR "ICK qualified material mismatch for ${key}: expected ${expected}, observed ${observed}")
  endif()
  if("${key}" MATCHES "[\t\r\n]" OR "${canonical}" MATCHES "[\t\r\n]" OR
      "${path}" MATCHES "[\t\r\n]")
    message(FATAL_ERROR "ICK material paths cannot contain tabs or newlines: ${key}")
  endif()
  set(content "${${variable}}file\t${key}\t${canonical}\t${path}\t${observed}\t${guard}\n")
  set(${variable} "${content}" PARENT_SCOPE)
endfunction()

# Resolve an installed ABI stage using the same mapping as action outputs.
# The shared Makefile is the single source of ABI flags and executable paths.
function(ick_android_stage)
  cmake_parse_arguments(STAGE "" "ROOT;FORTIFY_SOURCE" "" ${ARGN})
  if(STAGE_UNPARSED_ARGUMENTS OR NOT STAGE_ROOT OR NOT IS_ABSOLUTE "${STAGE_ROOT}")
    message(FATAL_ERROR "ick_android_stage requires an absolute ROOT")
  endif()
  if(NOT ANDROID_ABI)
    message(FATAL_ERROR "ick_android_stage requires ANDROID_ABI from the NDK toolchain")
  endif()
  find_program(ICK_STAGE_MAKE NAMES gmake make REQUIRED)
  execute_process(
    COMMAND "${ICK_STAGE_MAKE}" --no-print-directory -s
      -f "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/Makefile" outputs
      "ABI=${ANDROID_ABI}" "ICK_STAGE=${STAGE_ROOT}" "FORTIFY_SOURCE=${STAGE_FORTIFY_SOURCE}"
    RESULT_VARIABLE stage_result OUTPUT_VARIABLE stage_output ERROR_VARIABLE stage_error)
  if(NOT stage_result EQUAL 0)
    message(FATAL_ERROR "Cannot read ICK stage metadata: ${stage_error}")
  endif()
  foreach(field compiler target_flags header_target gnu_target material_records policy)
    string(REGEX MATCH "(^|\n)${field}=([^\n]*)" field_match "${stage_output}")
    if(NOT field_match OR "${CMAKE_MATCH_2}" STREQUAL "")
      message(FATAL_ERROR "ICK stage metadata is missing ${field}")
    endif()
    string(TOUPPER "${field}" variable)
    set("ICK_${variable}" "${CMAKE_MATCH_2}" PARENT_SCOPE)
  endforeach()
  string(REGEX MATCH "(^|\n)header_overlay=([^\n]*)" overlay_match "${stage_output}")
  if(overlay_match)
    set(ICK_HEADER_OVERLAY "${CMAKE_MATCH_2}" PARENT_SCOPE)
  else()
    set(ICK_HEADER_OVERLAY "" PARENT_SCOPE)
  endif()
endfunction()

# Compile only the explicitly listed, application-owned C translation units.
# The caller keeps NDK glue in its normal target source list and links these
# generated objects with the NDK toolchain. No C source reaches the assembler.
function(ick_android_objects output)
  cmake_parse_arguments(OWNED "" "NAME;STANDARD"
    "SOURCES;INCLUDES;OPTIONS;DEFINITIONS;MATERIALS;POLICIES" ${ARGN})
  if(OWNED_UNPARSED_ARGUMENTS OR NOT OWNED_NAME OR NOT OWNED_SOURCES)
    message(FATAL_ERROR "ick_android_objects needs NAME and SOURCES; unknown arguments: ${OWNED_UNPARSED_ARGUMENTS}")
  endif()
  if(NOT OWNED_MATERIALS AND DEFINED ICK_MATERIAL_RECORDS)
    set(OWNED_MATERIALS ${ICK_MATERIAL_RECORDS})
  endif()
  if(NOT OWNED_POLICIES AND DEFINED ICK_POLICY)
    set(OWNED_POLICIES ${ICK_POLICY})
  endif()
  if(NOT OWNED_MATERIALS OR NOT OWNED_POLICIES)
    message(FATAL_ERROR "ick_android_objects requires qualified MATERIALS and POLICIES, directly or from ick_android_stage")
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
  execute_process(COMMAND "${ICK_COMPILER}" ${ick_support} -print-file-name=include
    OUTPUT_VARIABLE builtin_include OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE builtin_result)
  execute_process(COMMAND "${ICK_COMPILER}" ${ick_support} -print-prog-name=cc1
    OUTPUT_VARIABLE cc1 OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE cc1_result)
  if(NOT builtin_result EQUAL 0 OR NOT IS_ABSOLUTE "${builtin_include}" OR
      NOT EXISTS "${builtin_include}/stdatomic.h" OR NOT EXISTS "${builtin_include}/stddef.h")
    message(FATAL_ERROR "The selected ICK compiler lacks its own builtin include directory: ${builtin_include}")
  endif()
  if(NOT cc1_result EQUAL 0 OR NOT IS_ABSOLUTE "${cc1}" OR NOT EXISTS "${cc1}")
    message(FATAL_ERROR "The selected ICK compiler lacks its cc1 child: ${cc1}")
  endif()
  get_filename_component(compiler_real "${ICK_COMPILER}" REALPATH)
  get_filename_component(cc1_real "${cc1}" REALPATH)
  get_filename_component(assembler_real "${CMAKE_C_COMPILER}" REALPATH)
  get_filename_component(compiler_bin "${compiler_real}" DIRECTORY)
  get_filename_component(compiler_stage "${compiler_bin}" DIRECTORY)

  set(header_overlay)
  if(ICK_HEADER_OVERLAY)
    if(NOT IS_ABSOLUTE "${ICK_HEADER_OVERLAY}" OR NOT IS_DIRECTORY "${ICK_HEADER_OVERLAY}")
      message(FATAL_ERROR "ICK_HEADER_OVERLAY must name the qualified adapter include directory")
    endif()
    list(APPEND header_overlay "-I${ICK_HEADER_OVERLAY}")
  endif()
  if(CMAKE_ANDROID_ARCH_ABI STREQUAL "armeabi-v7a")
    set(expected_target arm-linux-gnueabi)
    set(expected_headers arm-linux-androideabi)
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "arm64-v8a")
    set(expected_target aarch64-linux-gnu)
    set(expected_headers aarch64-linux-android)
  elseif(CMAKE_ANDROID_ARCH_ABI STREQUAL "x86_64")
    set(expected_target x86_64-linux-gnu x86_64-pc-linux-gnu)
    set(expected_headers x86_64-linux-android)
  else()
    message(FATAL_ERROR "OwnedC.cmake has no qualified ICK target for ${CMAKE_ANDROID_ARCH_ABI}")
  endif()
  execute_process(COMMAND "${ICK_COMPILER}" ${ick_support} -dumpmachine
    OUTPUT_VARIABLE actual_target OUTPUT_STRIP_TRAILING_WHITESPACE
    RESULT_VARIABLE target_result)
  if(NOT target_result EQUAL 0 OR NOT actual_target IN_LIST expected_target OR NOT ICK_HEADER_TARGET STREQUAL expected_headers)
    message(FATAL_ERROR "ICK target/header mismatch: ${actual_target}, ${ICK_HEADER_TARGET}; expected ${expected_target}, ${expected_headers}")
  endif()

  set(compiler_record)
  set(ndk_record)
  foreach(record IN LISTS OWNED_MATERIALS OWNED_POLICIES)
    if(NOT IS_ABSOLUTE "${record}" OR NOT EXISTS "${record}")
      message(FATAL_ERROR "Qualified ICK material record is missing: ${record}")
    endif()
    get_filename_component(record_name "${record}" NAME)
    if(record_name STREQUAL "compiler.sha256")
      set(compiler_record "${record}")
    elseif(record_name STREQUAL "ndk.sha256")
      set(ndk_record "${record}")
    endif()
  endforeach()
  if(NOT compiler_record OR NOT ndk_record)
    message(FATAL_ERROR "Qualified ICK materials must include compiler.sha256 and ndk.sha256")
  endif()
  _ick_record_hash("${compiler_record}" 0 expected_compiler)
  _ick_record_hash("${compiler_record}" 1 expected_cc1)
  _ick_record_hash("${ndk_record}" 0 expected_ndk_source)
  _ick_record_hash("${ndk_record}" 1 expected_assembler)

  if(DEFINED CMAKE_ANDROID_NDK AND NOT "${CMAKE_ANDROID_NDK}" STREQUAL "")
    set(ndk_root "${CMAKE_ANDROID_NDK}")
  else()
    get_filename_component(ndk_root "${CMAKE_SYSROOT}/../../../../" ABSOLUTE)
  endif()
  set(ndk_source_properties "${ndk_root}/source.properties")
  if(NOT EXISTS "${ndk_source_properties}")
    message(FATAL_ERROR "The selected Android NDK has no source.properties: ${ndk_source_properties}")
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

  set(path_mappings
    "${builtin_include}|@builtin@"
    "${ICK_HEADER_OVERLAY}|@overlay@"
    "${CMAKE_SYSROOT}|@sysroot@"
    "${compiler_stage}|@compiler-stage@"
    "${CMAKE_CURRENT_FUNCTION_LIST_DIR}|@interface@"
    "${CMAKE_CURRENT_BINARY_DIR}|@binary@"
    "${CMAKE_CURRENT_SOURCE_DIR}|@source@"
    "${ndk_root}|@ndk@")

  set(objects)
  set(receipts)
  foreach(source IN LISTS OWNED_SOURCES)
    if(NOT source MATCHES "\\.c$")
      message(FATAL_ERROR "OwnedC.cmake only accepts C source: ${source}")
    endif()
    get_filename_component(source_absolute "${source}" ABSOLUTE BASE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    get_filename_component(source_name "${source}" NAME)
    string(SHA256 source_key "${source_absolute}")
    string(SUBSTRING "${source_key}" 0 12 source_key)
    set(object_directory "${CMAKE_CURRENT_BINARY_DIR}/ick/${OWNED_NAME}")
    file(MAKE_DIRECTORY "${object_directory}")
    set(object "${object_directory}/${source_name}-${source_key}.o")
    set(assembly "${object}.s")
    set(dependencies "${object}.d")
    set(material_spec "${object}.material-spec.tsv")
    set(material_manifest "${object}.material.tsv")
    set(material_guard "${object}.material-guard")
    set(receipt "${object}.receipt.tsv")

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
    set(reproducible_paths
      "-ffile-prefix-map=${CMAKE_CURRENT_BINARY_DIR}=@binary@"
      "-ffile-prefix-map=${CMAKE_CURRENT_SOURCE_DIR}=@source@")
    # Preserve the complete inherited NDK flags, including Fortify, stack
    # protection, warnings and build-type optimization. An unsupported flag or
    # header is a compiler failure; do not erase it or retry with stock C.
    set(owned_flags)
    foreach(flag IN LISTS c_flags configuration_flags directory_options
        OWNED_OPTIONS source_COMPILE_OPTIONS source_flags)
      if(flag STREQUAL "-fno-limit-debug-info")
        list(APPEND owned_flags -fno-eliminate-unused-debug-types)
      else()
        list(APPEND owned_flags "${flag}")
      endif()
    endforeach()

    set(material_spec_content "schema\tick-android-material-spec-v1\n")
    foreach(mapping IN LISTS path_mappings)
      string(REPLACE "|" ";" mapping_parts "${mapping}")
      list(GET mapping_parts 0 mapping_root)
      list(GET mapping_parts 1 mapping_name)
      if(NOT "${mapping_root}" STREQUAL "")
        string(APPEND material_spec_content "map\t${mapping_root}\t${mapping_name}\n")
      endif()
    endforeach()
    _ick_canonicalize("${source_absolute}" source_canonical ${path_mappings})
    _ick_canonicalize("${assembly}" assembly_canonical ${path_mappings})
    _ick_append_value(material_spec_content source "${source_canonical}")
    _ick_append_value(material_spec_content assembly "${assembly_canonical}")
    _ick_append_value(material_spec_content target "${actual_target}")
    _ick_append_value(material_spec_content abi "${CMAKE_ANDROID_ARCH_ABI}")
    _ick_append_value(material_spec_content api "${ANDROID_PLATFORM_LEVEL}")
    _ick_append_value(material_spec_content standard "c${OWNED_STANDARD}")
    set(profile_index 0)
    foreach(profile_value IN LISTS ick_support ick_target owned_flags reproducible_paths
        header_overlay includes definitions assembler_target)
      _ick_canonicalize("${profile_value}" profile_canonical ${path_mappings})
      _ick_append_value(material_spec_content "profile.${profile_index}" "${profile_canonical}")
      math(EXPR profile_index "${profile_index} + 1")
    endforeach()

    _ick_append_file(material_spec_content source "${source_canonical}" "${source_absolute}" tracked "")
    _ick_append_file(material_spec_content compiler "@compiler-stage@/bin/${actual_target}-gcc" "${compiler_real}" qualified "${expected_compiler}")
    _ick_append_file(material_spec_content cc1 "@compiler-stage@/libexec/cc1" "${cc1_real}" qualified "${expected_cc1}")
    _ick_append_file(material_spec_content assembler "@ndk@/toolchains/llvm/prebuilt/linux-x86_64/bin/clang" "${assembler_real}" qualified "${expected_assembler}")
    _ick_append_file(material_spec_content ndk-source-properties "@ndk@/source.properties" "${ndk_source_properties}" qualified "${expected_ndk_source}")
    _ick_append_file(material_spec_content builtin-stdatomic "@builtin@/stdatomic.h" "${builtin_include}/stdatomic.h" qualified "")
    _ick_append_file(material_spec_content builtin-stddef "@builtin@/stddef.h" "${builtin_include}/stddef.h" qualified "")
    _ick_append_file(material_spec_content recipe "@interface@/OwnedC.cmake" "${CMAKE_CURRENT_FUNCTION_LIST_FILE}" tracked "")
    set(record_index 0)
    foreach(record IN LISTS OWNED_MATERIALS)
      _ick_canonicalize("${record}" record_canonical ${path_mappings})
      _ick_append_file(material_spec_content "closure.${record_index}" "${record_canonical}" "${record}" qualified "")
      math(EXPR record_index "${record_index} + 1")
    endforeach()
    set(policy_index 0)
    foreach(policy IN LISTS OWNED_POLICIES)
      _ick_canonicalize("${policy}" policy_canonical ${path_mappings})
      _ick_append_file(material_spec_content "policy.${policy_index}" "${policy_canonical}" "${policy}" qualified "")
      math(EXPR policy_index "${policy_index} + 1")
    endforeach()
    file(GENERATE OUTPUT "${material_spec}" CONTENT "${material_spec_content}")
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS
      "${CMAKE_CURRENT_FUNCTION_LIST_FILE}"
      "${compiler_real}" "${cc1_real}" "${assembler_real}"
      "${ndk_source_properties}"
      "${builtin_include}/stdatomic.h" "${builtin_include}/stddef.h"
      ${OWNED_MATERIALS} ${OWNED_POLICIES})

    string(SHA256 guard_key "${CMAKE_CURRENT_BINARY_DIR}|${OWNED_NAME}|${source_key}")
    string(SUBSTRING "${guard_key}" 0 16 guard_key)
    set(guard_target "ick-material-${guard_key}")
    add_custom_target("${guard_target}"
      COMMAND "${CMAKE_COMMAND}"
        "-DSPEC=${material_spec}" "-DDEPFILE=${dependencies}"
        "-DOBJECT=${object}" "-DASSEMBLY=${assembly}"
        "-DMANIFEST=${material_manifest}" "-DRECEIPT=${receipt}"
        "-DGUARD=${material_guard}"
        -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/VerifyMaterial.cmake"
      BYPRODUCTS "${material_guard}"
      VERBATIM)
    add_custom_command(
      OUTPUT "${object}"
      BYPRODUCTS "${assembly}" "${dependencies}" "${material_manifest}" "${receipt}"
      COMMAND "${CMAKE_COMMAND}" -E make_directory "${object_directory}"
      COMMAND "${ICK_COMPILER}" ${ick_support} ${ick_target}
        ${owned_flags} ${reproducible_paths}
        "--sysroot=${CMAKE_SYSROOT}"
        ${header_overlay}
        -nostdinc -isystem "${builtin_include}"
        -isystem "${CMAKE_SYSROOT}/usr/include"
        -isystem "${CMAKE_SYSROOT}/usr/include/${ICK_HEADER_TARGET}"
        -D__ANDROID__ "-D__ANDROID_API__=${ANDROID_PLATFORM_LEVEL}"
        "-D__ANDROID_MIN_SDK_VERSION__=${ANDROID_PLATFORM_LEVEL}"
        -DBIONIC_IOCTL_NO_SIGNEDNESS_OVERLOAD "-std=c${OWNED_STANDARD}" -fPIC
        -gno-variable-location-views -gdwarf-4
        ${includes} ${definitions}
        -MD -MT "${object}" -MF "${dependencies}"
        -S "${source_absolute}" -o "${assembly}"
      COMMAND "${CMAKE_C_COMPILER}" ${assembler_target} ${ick_target}
        "--sysroot=${CMAKE_SYSROOT}" -c "${assembly}" -o "${object}"
      COMMAND "${CMAKE_COMMAND}"
        "-DSPEC=${material_spec}" "-DDEPFILE=${dependencies}"
        "-DOBJECT=${object}" "-DASSEMBLY=${assembly}"
        "-DMANIFEST=${material_manifest}" "-DRECEIPT=${receipt}"
        -P "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/WriteObjectReceipt.cmake"
      DEPENDS "${source_absolute}" "${ICK_COMPILER}" "${material_guard}" "${guard_target}"
      DEPFILE "${dependencies}"
      COMMAND_EXPAND_LISTS
      VERBATIM
      COMMENT "ICK C and NDK assembly: ${source_name}"
    )
    set_source_files_properties("${object}" PROPERTIES EXTERNAL_OBJECT TRUE GENERATED TRUE)
    list(APPEND objects "${object}")
    list(APPEND receipts "${receipt}")
  endforeach()
  set(${output} "${objects}" PARENT_SCOPE)
  set(${output}_MATERIAL_RECEIPTS "${receipts}" PARENT_SCOPE)
endfunction()
