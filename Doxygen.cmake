find_package(Doxygen)

if(DOXYGEN_EXECUTABLE)
    add_custom_target(doc)
endif()

set(DOXYGEN_CONFIG_IN_FILE "${CMAKE_CURRENT_LIST_DIR}/doxyfile.in")

function(add_doxygen ARG_NAME ARG_VERSION)
    if(NOT DOXYGEN_EXECUTABLE)
        return()
    endif()

    cmake_parse_arguments(ARG "" ""
        "INPUTS;IMAGE_PATHS"
        ${ARGN}
    )

    set(DOC_OUTPUT_PATH    "${CMAKE_CURRENT_BINARY_DIR}/${ARG_NAME}-${ARG_VERSION}-doc")
    set(DOC_OUTPUT_PACKAGE "${DOC_OUTPUT_PATH}.tar.gz")
    set(DOC_CONFIG_FILE    "${DOC_OUTPUT_PATH}.config")
    set(DOC_README         "${CMAKE_CURRENT_SOURCE_DIR}/README.md")

    string(REPLACE ";" "\" \"" DOC_INPUTS "\"${ARG_INPUTS}\"")
    string(REPLACE ";" "\" \"" DOC_IMAGE_PATHS "\"${ARG_IMAGE_PATHS}\"")

    configure_file("${DOXYGEN_CONFIG_IN_FILE}" "${DOC_CONFIG_FILE}" @ONLY)

    add_custom_command(
        OUTPUT "${DOC_OUTPUT_PATH}" "${DOC_OUTPUT_PACKAGE}"
        COMMAND "${CMAKE_COMMAND}" -E make_directory "${DOC_OUTPUT_PATH}"
        COMMAND "${DOXYGEN_EXECUTABLE}" "${DOC_CONFIG_FILE}"
        COMMAND "${CMAKE_COMMAND}" -E tar "cfz" "${DOC_OUTPUT_PACKAGE}" "${DOC_OUTPUT_PATH}"
        DEPENDS "${ARG_INPUTS}" "${IMAGE_PATHS}" "${DOC_README}"
    )

    add_custom_target(${ARG_NAME}-doc DEPENDS "${DOC_OUTPUT_PACKAGE}")
    add_dependencies(doc ${ARG_NAME}-doc)
endfunction(add_doxygen)
