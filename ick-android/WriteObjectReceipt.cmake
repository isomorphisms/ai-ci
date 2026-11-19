cmake_minimum_required(VERSION 3.22)

foreach(required SPEC DEPFILE OBJECT ASSEMBLY MANIFEST RECEIPT)
  if(NOT DEFINED ${required} OR "${${required}}" STREQUAL "")
    message(FATAL_ERROR "WriteObjectReceipt.cmake requires ${required}")
  endif()
endforeach()
foreach(required_file SPEC DEPFILE OBJECT ASSEMBLY)
  if(NOT EXISTS "${${required_file}}")
    message(FATAL_ERROR "Cannot write ICK object receipt; ${required_file} is missing: ${${required_file}}")
  endif()
endforeach()

include("${CMAKE_CURRENT_LIST_DIR}/VerifyMaterial.cmake")
ick_material_collect("${SPEC}" "${DEPFILE}" material_manifest material_sha)
file(SHA256 "${ASSEMBLY}" assembly_sha)
file(SHA256 "${OBJECT}" object_sha)
file(WRITE "${MANIFEST}" "${material_manifest}")
file(WRITE "${RECEIPT}"
  "schema\tick-android-object-v1\n"
  "material_sha256\t${material_sha}\n"
  "assembly_sha256\t${assembly_sha}\n"
  "object_sha256\t${object_sha}\n")
