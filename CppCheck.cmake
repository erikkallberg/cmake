find_program(CPPCHECK_EXECUTABLE cppcheck)

if(CPPCHECK_EXECUTABLE)
    add_custom_target(cppcheck)

    execute_process(COMMAND ${CPPCHECK_EXECUTABLE} "--version"
                    OUTPUT_VARIABLE CPPCHECK_VERSION
    )
    string(REGEX MATCH "[0-9]+\\.[0-9]+" CPPCHECK_VERSION "${CPPCHECK_VERSION}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(Cppcheck
                                  REQUIRED_VARS CPPCHECK_EXECUTABLE
                                  VERSION_VAR CPPCHECK_VERSION)

function(prepend_elements LIST STR)
    string(REPLACE ";" ";${STR}" RESULT "${STR}${${LIST}}")
    set(${LIST} ${RESULT} PARENT_SCOPE)
endfunction(prepend_elements)

set(CPPCHECK_GTEST_CFG "${CMAKE_CURRENT_LIST_DIR}/cppcheck_gtest.cfg")

function(add_cppcheck ARG_NAME)
    if(NOT CPPCHECK_EXECUTABLE)
        return()
    endif()

    cmake_parse_arguments(ARG
        "GTEST_CFG"
        ""
        "SOURCES;INCLUDE_DIRS;INCLUDE_TARGETS;SUPPRESS;DEPENDS;ARGS"
        ${ARGN}
    )

    get_directory_property(INCLUDE_DIR_LIST INCLUDE_DIRECTORIES)

    foreach(TARGET ${ARG_INCLUDE_TARGETS} ${ARG_DEPENDS})
        get_target_property(TEMP_LIST ${TARGET} INCLUDE_DIRECTORIES)
        list(APPEND INCLUDE_DIR_LIST ${TEMP_LIST})
    endforeach()

    list(APPEND INCLUDE_DIR_LIST ${ARG_INCLUDE_DIRS})
    prepend_elements(INCLUDE_DIR_LIST "-I")

    if(ARG_SUPPRESS)
        prepend_elements(ARG_SUPPRESS "--suppress=")
    endif()

    if(ARG_GTEST_CFG)
        set(ARG_ARGS "--library=${CPPCHECK_GTEST_CFG}" ${ARG_ARGS})
    endif()

    add_custom_target(${ARG_NAME}-cppcheck
        COMMAND "${CPPCHECK_EXECUTABLE}"
                --enable=all
                --inline-suppr
                --language=c++
                --platform=unix32
                --relative-paths=${CMAKE_CURRENT_SOURCE_DIR}
                ${INCLUDE_DIR_LIST}
                ${ARG_SUPPRESS}
                ${ARG_ARGS}
                ${ARG_SOURCES}
        DEPENDS ${ARG_SOURCES} ${ARG_DEPENDS}
        COMMENT "Executing cppcheck for ${ARG_NAME}"
    )

    add_dependencies(cppcheck ${ARG_NAME}-cppcheck)
endfunction(add_cppcheck)
