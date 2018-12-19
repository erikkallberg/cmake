find_program(LCOV_EXECUTABLE lcov)
find_program(GENHTML_EXECUTABLE genhtml)

if(LCOV_EXECUTABLE)
    execute_process(COMMAND ${LCOV_EXECUTABLE} "-version"
                    OUTPUT_VARIABLE LCOV_VERSION
    )
    string(REGEX MATCH "[0-9]+\\.[0-9]+" LCOV_VERSION "${LCOV_VERSION}")
endif()

if(GENHTML_EXECUTABLE)
    execute_process(COMMAND ${GENHTML_EXECUTABLE} "-version"
                    OUTPUT_VARIABLE GENHTML_VERSION
    )
    string(REGEX MATCH "[0-9]+\\.[0-9]+" GENHTML_VERSION "${GENHTML_VERSION}")
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(lcov
                                  REQUIRED_VARS LCOV_EXECUTABLE
                                  VERSION_VAR LCOV_VERSION)
find_package_handle_standard_args(genhtml
                                  REQUIRED_VARS GENHTML_EXECUTABLE
                                  VERSION_VAR GENHTML_VERSION)

if(NOT (GCOV_EXECUTABLE AND LCOV_EXECUTABLE AND GENHTML_EXECUTABLE))
    return()
endif()

if(NOT TARGET coverage)
    add_custom_target(coverage)
endif()

function(add_coverage_lcov ARG_NAME)
    cmake_parse_arguments(ARG "" ""
        "SOURCES;TEST_NAMES"
        ${ARGN}
    )

    set(COVERAGE_OUTPUT_PATH    "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}-coverage")
    set(COVERAGE_OUTPUT_PACKAGE "${COVERAGE_OUTPUT_PATH}.tar.gz")
    set(COVERAGE_INFO_FILE      "${COVERAGE_OUTPUT_PATH}.info")

    get_test_binary(TEST_BINARIES ${ARG_TEST_NAMES})

    add_custom_command(
        OUTPUT "${COVERAGE_OUTPUT_PATH}" "${COVERAGE_OUTPUT_PACKAGE}" "${COVERAGE_INFO_FILE}"

        # Clean old output
        COMMAND "${CMAKE_COMMAND}" -E remove_directory "${COVERAGE_OUTPUT_PATH}"
        COMMAND "${CMAKE_COMMAND}" -E remove "${COVERAGE_INFO_FILE}"

        # Execute tests
        COMMAND "${CMAKE_COMMAND}" --build "${CMAKE_CURRENT_BINARY_DIR}" --target ${ARG_TEST_NAMES}

        # Collect execution statistics into info file
        COMMAND "${LCOV_EXECUTABLE}" -c -q
            -o "${COVERAGE_INFO_FILE}"
            -d "${CMAKE_CURRENT_BINARY_DIR}"
            -b "${CMAKE_CURRENT_SOURCE_DIR}"
            --gcov-tool "${GCOV_EXECUTABLE}"
            --no-external

        # Extract from info file only required sources
        COMMAND "${LCOV_EXECUTABLE}" -q
            -e "${COVERAGE_INFO_FILE}" ${ARG_SOURCES}
            -o "${COVERAGE_INFO_FILE}"

        # Generate HTML report
        COMMAND "${GENHTML_EXECUTABLE}"
            -o "${COVERAGE_OUTPUT_PATH}"
            -t "${ARG_NAME} ${ARG_VERSION}"
            "${COVERAGE_INFO_FILE}"

        # Create archive with HTML report
        COMMAND "${CMAKE_COMMAND}" -E tar "cfz" "${COVERAGE_OUTPUT_PACKAGE}" "${COVERAGE_OUTPUT_PATH}"

        DEPENDS clean-gcda ${ARG_SOURCES} ${TEST_BINARIES}
    )

    add_custom_target(${ARG_NAME}-coverage
        DEPENDS "${COVERAGE_OUTPUT_PACKAGE}"
    )

    add_dependencies(coverage ${ARG_NAME}-coverage)
endfunction(add_coverage_lcov)
