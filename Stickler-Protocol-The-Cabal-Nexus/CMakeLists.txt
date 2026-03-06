cmake_minimum_required(VERSION 3.10)

# Project definition
project(SticklerProtocolCabalNexus VERSION 1.0 LANGUAGES CXX)

# Use modern C++
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Collect all .cpp files in this folder
file(GLOB SOURCES "*.cpp")

# Build executable from sources
add_executable(stickler_protocol ${SOURCES})

# Include headers if you have an "include" directory
include_directories(${PROJECT_SOURCE_DIR}/include)

# Enable testing (optional)
enable_testing()
add_test(NAME SticklerRun COMMAND stickler_protocol)
