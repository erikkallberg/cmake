add_custom_target(cpplint)

set(CPPLINT_EXECUTABLE "${CMAKE_CURRENT_LIST_DIR}/cpplint.py")

function(add_cpplint ARG_NAME)
    cmake_parse_arguments(ARG "" ""
        "SOURCES;ARGS"
        ${ARGN}
    )

    add_custom_target(${ARG_NAME}-cpplint
        COMMAND "${CPPLINT_EXECUTABLE}"
                --linelength=120
                ${ARG_ARGS}
                ${ARG_SOURCES}
        DEPENDS ${ARG_SOURCES}
        COMMENT "Executing cpplint for ${ARG_NAME}"
    )

    add_dependencies(cpplint ${ARG_NAME}-cpplint)
endfunction(add_cpplint)
