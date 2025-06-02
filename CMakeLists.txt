cmake_minimum_required(VERSION 3.14)
project(phonenumber-py)

# Set C++ standard
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

# Find Python
find_package(Python COMPONENTS Interpreter Development REQUIRED)

# Find libphonenumber
find_library(PHONENUMBER_LIB phonenumber 
    PATHS 
    /usr/lib 
    /usr/local/lib 
    /usr/lib/x86_64-linux-gnu
    /usr/lib/aarch64-linux-gnu)

if(NOT PHONENUMBER_LIB)
    message(FATAL_ERROR "libphonenumber not found. Please install libphonenumber-dev package.")
endif()

find_path(PHONENUMBER_INCLUDE_DIR phonenumbers/phonenumberutil.h
    PATHS
    /usr/include
    /usr/local/include
    /usr/include/phonenumbers)

if(NOT PHONENUMBER_INCLUDE_DIR)
    message(FATAL_ERROR "libphonenumber headers not found. Please install libphonenumber-dev package.")
endif()

message(STATUS "Found libphonenumber: ${PHONENUMBER_LIB}")
message(STATUS "Found libphonenumber headers: ${PHONENUMBER_INCLUDE_DIR}")

# Set up Cython
find_program(CYTHON_EXECUTABLE NAMES cython cython3)
if(NOT CYTHON_EXECUTABLE)
  message(FATAL_ERROR "Cython executable not found")
endif()

# Cython wrapper build
add_custom_command(
  OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/phonenumber.cpp
  COMMAND ${CYTHON_EXECUTABLE} -3 --cplus -o ${CMAKE_CURRENT_BINARY_DIR}/phonenumber.cpp 
          ${CMAKE_CURRENT_SOURCE_DIR}/src/phonenumber/phonenumber.pyx
  DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/src/phonenumber/phonenumber.pyx
          ${CMAKE_CURRENT_SOURCE_DIR}/src/phonenumber/phonenumber_defs.pxd
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  COMMENT "Cythonizing phonenumber.pyx"
)

# Create the extension module
Python_add_library(phonenumber MODULE ${CMAKE_CURRENT_BINARY_DIR}/phonenumber.cpp)
target_include_directories(phonenumber PRIVATE ${PHONENUMBER_INCLUDE_DIR})
target_link_libraries(phonenumber PRIVATE ${PHONENUMBER_LIB})

# Set the output directory
set_target_properties(phonenumber PROPERTIES
  LIBRARY_OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/phonenumber"
  PREFIX ""
  OUTPUT_NAME "phonenumber"
  SUFFIX "${Python_EXTENSION_SUFFIX}"
)

# Install the extension
install(TARGETS phonenumber
  LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}
)