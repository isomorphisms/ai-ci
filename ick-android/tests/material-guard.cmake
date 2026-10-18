cmake_minimum_required(VERSION 3.22)

get_filename_component(interface_root "${CMAKE_CURRENT_LIST_DIR}/.." ABSOLUTE)
if(NOT DEFINED TEST_ROOT OR TEST_ROOT STREQUAL "")
  set(TEST_ROOT "${CMAKE_CURRENT_BINARY_DIR}/ick-material-guard-test")
endif()
file(REMOVE_RECURSE "${TEST_ROOT}")
file(MAKE_DIRECTORY "${TEST_ROOT}")

function(material_paths root)
  set(source "${root}/source-root/unit.c" PARENT_SCOPE)
  set(user "${root}/source-root/unit.h" PARENT_SCOPE)
  set(system "${root}/sysroot/usr/include/stdint.h" PARENT_SCOPE)
  set(builtin "${root}/builtin-root/stddef.h" PARENT_SCOPE)
  set(compiler "${root}/stage/bin/gcc" PARENT_SCOPE)
  set(cc1 "${root}/stage/libexec/cc1" PARENT_SCOPE)
  set(assembler "${root}/assembler" PARENT_SCOPE)
  set(recipe "${root}/interface-root/OwnedC.cmake" PARENT_SCOPE)
  set(closure "${root}/stage/qualification/artifacts.sha256" PARENT_SCOPE)
  set(policy "${root}/stage/qualification/receipt.tsv" PARENT_SCOPE)
  set(object "${root}/build-root/unit.o" PARENT_SCOPE)
  set(assembly "${root}/build-root/unit.o.s" PARENT_SCOPE)
  set(depfile "${root}/build-root/unit.o.d" PARENT_SCOPE)
  set(manifest "${root}/build-root/unit.o.material.tsv" PARENT_SCOPE)
  set(receipt "${root}/build-root/unit.o.receipt.tsv" PARENT_SCOPE)
  set(guard "${root}/build-root/unit.o.guard" PARENT_SCOPE)
  set(spec "${root}/build-root/unit.o.spec.tsv" PARENT_SCOPE)
endfunction()

function(write_spec root api)
  material_paths("${root}")
  foreach(path compiler cc1 assembler builtin closure policy)
    file(SHA256 "${${path}}" ${path}_sha)
  endforeach()
  file(WRITE "${spec}"
    "schema\tick-android-material-spec-v1\n"
    "map\t${root}/source-root\t@source@\n"
    "map\t${root}/sysroot\t@sysroot@\n"
    "map\t${root}/builtin-root\t@builtin@\n"
    "map\t${root}/stage\t@compiler-stage@\n"
    "map\t${root}/interface-root\t@interface@\n"
    "map\t${root}/build-root\t@binary@\n"
    "value\tsource\t@source@/unit.c\n"
    "value\tassembly\t@binary@/unit.o.s\n"
    "value\ttarget\tx86_64-linux-gnu\n"
    "value\tabi\tx86_64\n"
    "value\tapi\t${api}\n"
    "value\tprofile.0\t-O2\n"
    "file\tsource\t@source@/unit.c\t${source}\tignored\ttracked\n"
    "file\tcompiler\t@compiler-stage@/bin/gcc\t${compiler}\t${compiler_sha}\tqualified\n"
    "file\tcc1\t@compiler-stage@/libexec/cc1\t${cc1}\t${cc1_sha}\tqualified\n"
    "file\tassembler\t@sysroot@/../bin/clang\t${assembler}\t${assembler_sha}\tqualified\n"
    "file\tbuiltin\t@builtin@/stddef.h\t${builtin}\t${builtin_sha}\tqualified\n"
    "file\trecipe\t@interface@/OwnedC.cmake\t${recipe}\tignored\ttracked\n"
    "file\tclosure.0\t@compiler-stage@/qualification/artifacts.sha256\t${closure}\t${closure_sha}\tqualified\n"
    "file\tpolicy.0\t@compiler-stage@/qualification/receipt.tsv\t${policy}\t${policy_sha}\tqualified\n")
endfunction()

function(run_receipt root)
  material_paths("${root}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
      "-DSPEC=${spec}" "-DDEPFILE=${depfile}"
      "-DOBJECT=${object}" "-DASSEMBLY=${assembly}"
      "-DMANIFEST=${manifest}" "-DRECEIPT=${receipt}"
      -P "${interface_root}/WriteObjectReceipt.cmake"
    RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error)
  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Writing the material receipt failed: ${output}${error}")
  endif()
endfunction()

function(run_verify root expected diagnostic)
  material_paths("${root}")
  execute_process(
    COMMAND "${CMAKE_COMMAND}"
      "-DSPEC=${spec}" "-DDEPFILE=${depfile}"
      "-DOBJECT=${object}" "-DASSEMBLY=${assembly}"
      "-DMANIFEST=${manifest}" "-DRECEIPT=${receipt}"
      "-DGUARD=${guard}"
      -P "${interface_root}/VerifyMaterial.cmake"
    RESULT_VARIABLE result OUTPUT_VARIABLE output ERROR_VARIABLE error)
  if(expected STREQUAL "PASS")
    if(NOT result EQUAL 0)
      message(FATAL_ERROR "Material verification unexpectedly failed: ${output}${error}")
    endif()
  else()
    if(result EQUAL 0)
      message(FATAL_ERROR "Material verification unexpectedly accepted ${diagnostic}")
    endif()
    if(NOT "${output}${error}" MATCHES "${diagnostic}")
      message(FATAL_ERROR "Material verification failed with the wrong diagnostic: ${output}${error}")
    endif()
  endif()
endfunction()

function(mock_compile root label)
  material_paths("${root}")
  file(WRITE "${assembly}" "assembly ${label}\n")
  file(WRITE "${object}" "object ${label}\n")
  file(WRITE "${depfile}" "${object}: ${source} ${user} ${system} ${builtin}\n")
  run_receipt("${root}")
endfunction()

function(expect_rebuild root path label refresh_spec)
  material_paths("${root}")
  file(APPEND "${path}" "\n/* ${label} */\n")
  if(refresh_spec)
    write_spec("${root}" 26)
  endif()
  run_verify("${root}" PASS "")
  if(EXISTS "${object}")
    message(FATAL_ERROR "${label} did not invalidate the existing object")
  endif()
  mock_compile("${root}" "${label}")
  run_verify("${root}" PASS "")
endfunction()

set(root "${TEST_ROOT}/original")
file(MAKE_DIRECTORY
  "${root}/source-root" "${root}/sysroot/usr/include"
  "${root}/builtin-root" "${root}/stage/bin" "${root}/stage/libexec"
  "${root}/stage/qualification" "${root}/interface-root" "${root}/build-root")
material_paths("${root}")

file(WRITE "${source}" "#include \"unit.h\"\n#include <stdint.h>\nint unit(void) { return VALUE; }\n")
file(WRITE "${user}" "#define VALUE 7\n")
file(WRITE "${system}" "typedef int int32_t;\n")
file(WRITE "${builtin}" "typedef __SIZE_TYPE__ size_t;\n")
file(WRITE "${compiler}" "qualified driver\n")
file(WRITE "${cc1}" "qualified cc1\n")
file(WRITE "${assembler}" "qualified assembler\n")
file(WRITE "${recipe}" "qualified recipe\n")
file(WRITE "${closure}" "qualified closure\n")
file(WRITE "${policy}" "material_policy\tick-android-material-v1\n")
file(WRITE "${depfile}" "${object}: ${source} ${user} ${system} ${builtin}\n")
write_spec("${root}" 26)
mock_compile("${root}" baseline)
run_verify("${root}" PASS "")

file(TIMESTAMP "${guard}" guard_before "%s")
execute_process(COMMAND "${CMAKE_COMMAND}" -E sleep 1)
run_verify("${root}" PASS "")
file(TIMESTAMP "${guard}" guard_after "%s")
if(NOT guard_before STREQUAL guard_after)
  message(FATAL_ERROR "Unchanged material rewrote the guard stamp")
endif()

expect_rebuild("${root}" "${source}" source FALSE)
expect_rebuild("${root}" "${user}" user-header FALSE)
expect_rebuild("${root}" "${system}" sysroot-header FALSE)
expect_rebuild("${root}" "${builtin}" builtin-header TRUE)
expect_rebuild("${root}" "${compiler}" compiler-driver TRUE)
expect_rebuild("${root}" "${assembler}" assembler-driver TRUE)
expect_rebuild("${root}" "${recipe}" recipe FALSE)
expect_rebuild("${root}" "${closure}" qualification-closure TRUE)
expect_rebuild("${root}" "${policy}" policy TRUE)

write_spec("${root}" 27)
run_verify("${root}" PASS "")
if(EXISTS "${object}")
  message(FATAL_ERROR "API profile change did not invalidate the existing object")
endif()
mock_compile("${root}" api-profile)

file(READ "${cc1}" cc1_original)
file(APPEND "${cc1}" "hidden backdated mutation\n")
execute_process(COMMAND touch -t 200001010000 "${cc1}" RESULT_VARIABLE touch_result)
if(NOT touch_result EQUAL 0)
  message(FATAL_ERROR "Cannot create the backdated cc1 control")
endif()
run_verify("${root}" FAIL "Qualified ICK material changed")
file(WRITE "${cc1}" "${cc1_original}")
write_spec("${root}" 27)
run_verify("${root}" PASS "")

file(WRITE "${object}" "copied stale object\n")
execute_process(COMMAND touch -t 203801010000 "${object}" RESULT_VARIABLE touch_result)
if(NOT touch_result EQUAL 0)
  message(FATAL_ERROR "Cannot create the future-dated object control")
endif()
run_verify("${root}" FAIL "object changed without recompilation")
mock_compile("${root}" restored)

set(relocated "${TEST_ROOT}/relocated")
file(MAKE_DIRECTORY "${relocated}")
file(COPY "${root}/" DESTINATION "${relocated}")
material_paths("${relocated}")
set(relocated_depfile "${relocated}/depfile")
file(READ "${relocated_depfile}" relocated_dependencies)
string(REPLACE "${root}" "${relocated}" relocated_dependencies "${relocated_dependencies}")
file(WRITE "${relocated_depfile}" "${relocated_dependencies}")
write_spec("${relocated}" 27)
run_verify("${relocated}" PASS "")

message(STATUS "ICK Android material guard: PASS")
