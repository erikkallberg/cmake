find_program(GCOVR_EXECUTABLE gcovr)

if(GCOVR_EXECUTABLE)
    execute_process(COMMAND env -u PYTHONHOME ${GCOVR_EXECUTABLE} "--version"
                    OUTPUT_VARIABLE GCOVR_VERSION
    )
    string(REGEX MATCH "[0-9]+\\.[0-9]+" GCOVR_VERSION "${GCOVR_VERSION}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(gcovr
                                  REQUIRED_VARS GCOVR_EXECUTABLE
                                  VERSION_VAR GCOVR_VERSION)

if(NOT (GCOV_EXECUTABLE AND GCOVR_EXECUTABLE))
    return()
endif()

if(GCOVR_VERSION VERSION_LESS 3.2)
    message("Gcovr version 3.2 or greater is required")
    return()
endif()

if(NOT TARGET coverage)
    add_custom_target(coverage)
endif()

function(add_coverage_gcovr ARG_NAME ARG_VERSION)
    cmake_parse_arguments(ARG "" ""
        "SOURCES;TEST_NAMES"
        ${ARGN}
    )

    set(COVERAGE_OUTPUT_PATH       "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}-${ARG_VERSION}-coverage")
    set(COVERAGE_OUTPUT_PACKAGE    "${COVERAGE_OUTPUT_PATH}.tar.gz")
    set(COVERAGE_BRIEF_OUTPUT_PATH "${COVERAGE_OUTPUT_PATH}.html")

    get_test_binary(TEST_BINARIES ${ARG_TEST_NAMES})
    string(REPLACE ";" ";--filter=" SOURCES_FILTER "--filter=${ARG_SOURCES}")

    set(GCOVR_COMMAND env -u PYTHONHOME "${GCOVR_EXECUTABLE}"
        --gcov-executable="${GCOV_EXECUTABLE}"
        --root="${CMAKE_CURRENT_SOURCE_DIR}"
        ${SOURCES_FILTER}
    )

    add_custom_command(
        OUTPUT "${COVERAGE_OUTPUT_PATH}" "${COVERAGE_OUTPUT_PACKAGE}" "${COVERAGE_BRIEF_OUTPUT_PATH}"

        # Clean old output
        COMMAND "${CMAKE_COMMAND}" -E remove "${COVERAGE_OUTPUT_PACKAGE}" "${COVERAGE_BRIEF_OUTPUT_PATH}"
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${COVERAGE_OUTPUT_PATH}"

        # Execute tests
        COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_CURRENT_BINARY_DIR}" --target ${ARG_TEST_NAMES}

        # Generate detailed HTML report
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${COVERAGE_OUTPUT_PATH}"
        COMMAND ${GCOVR_COMMAND} --html --html-details --output="${COVERAGE_OUTPUT_PATH}/index.html"

        # Create archive with detailed HTML report
        COMMAND "${CMAKE_COMMAND}" -E tar "cfz" "${COVERAGE_OUTPUT_PACKAGE}" "${COVERAGE_OUTPUT_PATH}"

        # Generate brief HTML report
        COMMAND ${GCOVR_COMMAND} --html --output="${COVERAGE_BRIEF_OUTPUT_PATH}"

        # Generate console report
        COMMAND ${GCOVR_COMMAND}

        DEPENDS clean-gcda ${ARG_SOURCES} ${TEST_BINARIES}
    )

    add_custom_target(${ARG_NAME}-coverage
        DEPENDS "${COVERAGE_BRIEF_OUTPUT_PATH}" "${COVERAGE_OUTPUT_PACKAGE}"
    )

    add_dependencies(coverage ${ARG_NAME}-coverage)
endfunction(add_coverage_gcovr)
