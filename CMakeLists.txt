cmake_minimum_required(VERSION 3.20)
project(closeio_phonenumbers LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

find_package(Python REQUIRED COMPONENTS Interpreter Development.Module)
find_package(pybind11 CONFIG REQUIRED)
find_package(ICU 4.4 REQUIRED COMPONENTS uc i18n)

include(FetchContent)
if(POLICY CMP0169)
  cmake_policy(SET CMP0169 OLD)
endif()

# Keep the C++ implementation and all of its embedded metadata reproducible.
# The Python package version starts with this upstream version.
set(LIBPHONENUMBER_VERSION "9.0.34")
set(
  LIBPHONENUMBER_ARCHIVE
  "${CMAKE_CURRENT_SOURCE_DIR}/vendor/libphonenumber-${LIBPHONENUMBER_VERSION}.tar.gz"
)
if(EXISTS "${LIBPHONENUMBER_ARCHIVE}")
  set(LIBPHONENUMBER_URL "${LIBPHONENUMBER_ARCHIVE}")
else()
  set(
    LIBPHONENUMBER_URL
    "https://codeload.github.com/google/libphonenumber/tar.gz/refs/tags/v${LIBPHONENUMBER_VERSION}"
  )
endif()
FetchContent_Declare(
  libphonenumber_upstream
  URL "${LIBPHONENUMBER_URL}"
  URL_HASH
    "SHA256=5d2a61572110f0538fdb1afbc1f8381426fbfbbf544b45e8ae905297f2f5befa"
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
  SOURCE_SUBDIR cpp
)

# libphonenumber falls back to this exact Abseil revision. Declare it first so
# platforms without a packaged Abseil use a verified local archive.
set(ABSEIL_COMMIT "273292d1cfc0a94a65082ee350509af1d113344d")
set(
  ABSEIL_ARCHIVE
  "${CMAKE_CURRENT_SOURCE_DIR}/vendor/abseil-cpp-273292d.tar.gz"
)
if(EXISTS "${ABSEIL_ARCHIVE}")
  set(ABSEIL_URL "${ABSEIL_ARCHIVE}")
else()
  set(
    ABSEIL_URL
    "https://codeload.github.com/abseil/abseil-cpp/tar.gz/${ABSEIL_COMMIT}"
  )
endif()
FetchContent_Declare(
  abseil-cpp
  URL "${ABSEIL_URL}"
  URL_HASH
    "SHA256=94aef187f688665dc299d09286bfa0d22c4ecb86a80b156dff6aabadc5a5c26d"
  DOWNLOAD_EXTRACT_TIMESTAMP TRUE
)

set(BUILD_GEOCODER ON CACHE BOOL "" FORCE)
set(BUILD_SHARED_LIBS OFF CACHE BOOL "" FORCE)
set(BUILD_STATIC_LIB ON CACHE BOOL "" FORCE)
set(BUILD_TESTING OFF CACHE BOOL "" FORCE)
set(REGENERATE_METADATA OFF CACHE BOOL "" FORCE)
set(USE_BOOST OFF CACHE BOOL "" FORCE)
set(USE_ICU_REGEXP ON CACHE BOOL "" FORCE)
set(USE_STDMUTEX ON CACHE BOOL "" FORCE)
FetchContent_GetProperties(libphonenumber_upstream)
if(NOT libphonenumber_upstream_POPULATED)
  FetchContent_Populate(libphonenumber_upstream)
endif()

# Never modify FetchContent's cached upstream checkout. Recreate a staging tree
# on every configuration so branch switches cannot reuse stale patched sources.
set(
  LIBPHONENUMBER_SOURCE_DIR
  "${CMAKE_CURRENT_BINARY_DIR}/libphonenumber-${LIBPHONENUMBER_VERSION}-patched"
)
file(REMOVE_RECURSE "${LIBPHONENUMBER_SOURCE_DIR}")
file(
  COPY "${libphonenumber_upstream_SOURCE_DIR}/"
  DESTINATION "${LIBPHONENUMBER_SOURCE_DIR}"
)

# Preserve the script subtag when the C++ geocoder selects a prefix map.
# Upstream's public overload currently discards it before calling the already
# script-aware MappingFileProvider.
set(
  LIBPHONENUMBER_GEOCODER_SOURCE
  "${LIBPHONENUMBER_SOURCE_DIR}/cpp/src/phonenumbers/geocoding/phonenumber_offline_geocoder.cc"
)
file(READ "${LIBPHONENUMBER_GEOCODER_SOURCE}" GEOCODER_SOURCE)
set(
  GEOCODER_SCRIPT_IGNORED
  [=[number, language.getLanguage(), "", language.getCountry());]=]
)
set(
  GEOCODER_SCRIPT_PRESERVED
  [=[number, language.getLanguage(), language.getScript(), language.getCountry());]=]
)
string(FIND "${GEOCODER_SOURCE}" "${GEOCODER_SCRIPT_IGNORED}" PATCH_INDEX)
if(PATCH_INDEX LESS 0)
  message(FATAL_ERROR "Unable to apply the geocoder script-subtag patch")
endif()
string(
  REPLACE
  "${GEOCODER_SCRIPT_IGNORED}"
  "${GEOCODER_SCRIPT_PRESERVED}"
  GEOCODER_SOURCE
  "${GEOCODER_SOURCE}"
)
file(WRITE "${LIBPHONENUMBER_GEOCODER_SOURCE}" "${GEOCODER_SOURCE}")

add_subdirectory(
  "${LIBPHONENUMBER_SOURCE_DIR}/cpp"
  "${libphonenumber_upstream_BINARY_DIR}"
  EXCLUDE_FROM_ALL
)
# Xcode 17 diagnoses deprecated constructs in pinned upstream dependencies.
set(
  LIBPHONENUMBER_APPLECLANG_OPTIONS
  "$<$<CXX_COMPILER_ID:AppleClang>:-Wno-error=deprecated-builtins>"
  "$<$<CXX_COMPILER_ID:AppleClang>:-Wno-error=deprecated-declarations>"
)
# GCC 14 diagnoses a false positive in AlmaLinux 8's Protobuf 3.5 headers.
target_compile_options(
  phonenumber PRIVATE
  "$<$<CXX_COMPILER_ID:GNU>:-Wno-error=array-bounds>"
  ${LIBPHONENUMBER_APPLECLANG_OPTIONS}
)
target_compile_options(
  geocoding PRIVATE ${LIBPHONENUMBER_APPLECLANG_OPTIONS}
)
target_compile_options(
  generate_geocoding_data PRIVATE ${LIBPHONENUMBER_APPLECLANG_OPTIONS}
)

pybind11_add_module(_native MODULE src/native.cpp)
target_include_directories(
  _native PRIVATE
  "${LIBPHONENUMBER_SOURCE_DIR}/cpp/src"
  "${ICU_INCLUDE_DIRS}"
)
target_compile_definitions(
  _native PRIVATE LIBPHONENUMBER_VERSION="${LIBPHONENUMBER_VERSION}"
)
target_link_libraries(
  _native PRIVATE geocoding phonenumber ICU::uc ICU::i18n
)

install(TARGETS _native LIBRARY DESTINATION phonenumbers)
