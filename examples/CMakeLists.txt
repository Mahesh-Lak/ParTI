cmake_minimum_required(VERSION 3.2)
project(ParTI)

if(USE_CUDA)
    file(GLOB_RECURSE EXAMPLE_SRCS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c" "*.cu")
else()
    file(GLOB_RECURSE EXAMPLE_SRCS RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}" "*.c")
endif()


foreach(EXAMPLE_SRC IN LISTS EXAMPLE_SRCS)
    get_filename_component(EXAMPLE_EXE "${EXAMPLE_SRC}" NAME_WE)
    if(USE_CUDA)
        cuda_add_executable("${EXAMPLE_EXE}" "${EXAMPLE_SRC}")
    else()
        add_executable("${EXAMPLE_EXE}" "${EXAMPLE_SRC}")
    endif()
    set_target_properties("${EXAMPLE_EXE}" PROPERTIES C_STANDARD 99)
    if(BUILD_STATIC)
        target_link_libraries("${EXAMPLE_EXE}" ParTI_s)
    else()
        target_link_libraries("${EXAMPLE_EXE}" ParTI)
    endif()
endforeach(EXAMPLE_SRC)
