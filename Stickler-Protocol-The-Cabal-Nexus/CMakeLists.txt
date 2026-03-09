cmake_minimum_required(VERSION 3.10)

# Project definition
project(SticklerProtocolCabalNexus VERSION 1.0 LANGUAGES CXX)

# Use modern C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Include headers if you have an "include" directory
include_directories(${PROJECT_SOURCE_DIR}/include)

# Build each .cpp in the root as a separate executable
# Each file is a self-contained program with its own main()
file(GLOB ROOT_SOURCES "${PROJECT_SOURCE_DIR}/*.cpp")
foreach(SOURCE_FILE ${ROOT_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE_FILE} NAME_WE)
    # Sanitize target name: replace dots, spaces, and special chars with underscores
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" SAFE_NAME "${EXEC_NAME}")
    add_executable(${SAFE_NAME} ${SOURCE_FILE})
endforeach()

# Build files in Input/output as separate executables
file(GLOB IO_SOURCES "${PROJECT_SOURCE_DIR}/Input/output/*.cpp")
foreach(SOURCE_FILE ${IO_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE_FILE} NAME_WE)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" SAFE_NAME "io_${EXEC_NAME}")
    add_executable(${SAFE_NAME} ${SOURCE_FILE})
endforeach()

# Enable testing
enable_testing()

# Add a test for each root executable
foreach(SOURCE_FILE ${ROOT_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE_FILE} NAME_WE)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" SAFE_NAME "${EXEC_NAME}")
    add_test(NAME test_${SAFE_NAME} COMMAND ${SAFE_NAME})
    # Allow tests to time out (some programs have infinite loops)
    set_tests_properties(test_${SAFE_NAME} PROPERTIES TIMEOUT 5)
endforeach()

foreach(SOURCE_FILE ${IO_SOURCES})
    get_filename_component(EXEC_NAME ${SOURCE_FILE} NAME_WE)
    string(REGEX REPLACE "[^a-zA-Z0-9_]" "_" SAFE_NAME "io_${EXEC_NAME}")
    add_test(NAME test_${SAFE_NAME} COMMAND ${SAFE_NAME})
    set_tests_properties(test_${SAFE_NAME} PROPERTIES TIMEOUT 5)
endforeach()
