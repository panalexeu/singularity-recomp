# singularity - ReXGlue Recompiled Project
#
# SDK boilerplate lives in generated/rexglue.cmake.

cmake_minimum_required(VERSION 3.25)
project(singularity LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(generated/rexglue.cmake)

# Sources
set(SINGULARITY_SOURCES
    src/main.cpp
)

if(WIN32)
    add_executable(singularity WIN32 ${SINGULARITY_SOURCES})
else()
    add_executable(singularity ${SINGULARITY_SOURCES})
endif()

rexglue_setup_target(singularity)

# Copy the runtime configuration next to the executable (the runtime reads <exe dir>/singularity.toml).
add_custom_command(TARGET singularity POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            ${CMAKE_CURRENT_SOURCE_DIR}/config/singularity.toml
            $<TARGET_FILE_DIR:singularity>/singularity.toml
    COMMENT "Copying config/singularity.toml next to the executable")
