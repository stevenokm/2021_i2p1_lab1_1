cmake_minimum_required(VERSION 3.2.2)

if(UNIX AND NOT APPLE)
  set(LINUX TRUE)
endif()

MACRO(SUBDIRLIST result curdir)
  FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
  SET(dirlist "")
  FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
      LIST(APPEND dirlist ${child})
    ENDIF()
  ENDFOREACH()
  SET(${result} ${dirlist})
ENDMACRO()

macro(use_cxx17)
  if (CMAKE_VERSION VERSION_LESS "3.1")
    if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
      set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++17")
    endif ()
  else ()
    set (CMAKE_CXX_STANDARD 17)
  endif ()
  if(APPLE)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -stdlib=libc++ -lc++abi")
  elseif(WIN32)
    set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS}")
  endif()
endmacro(use_cxx17)

use_cxx17()

if(UNIX)
  SUBDIRLIST(SUBDIRS ${CMAKE_SOURCE_DIR})
elseif(WIN32)
  SUBDIRLIST(SUBDIRS ${CMAKE_SOURCE_DIR}/src)
endif()
list(REMOVE_ITEM SUBDIRS "testbench" "CMakeFiles" "build" "jplag" "jplag_result" ".git" ".vscode")

project(lab1_1)

FOREACH(subdir ${SUBDIRS})
  if(UNIX)
    set(src_path "${subdir}")
  elseif(WIN32)
    set(src_path "src/${subdir}")
  endif()
  get_filename_component(bin_name_string ${subdir} NAME)
  string(REPLACE " " ";" bin_name_list ${bin_name_string})
  list(GET bin_name_list 0 bin_name)
  set(bin_prefix "${CMAKE_PROJECT_NAME}_")
  set(main_cpp "${src_path}/${bin_prefix}${bin_name}.cpp")
  file(GLOB SRCS "${src_path}/*.cpp" "${src_path}/*.h")
  list(REMOVE_ITEM SRCS ${main_cpp})
  if(EXISTS ${CMAKE_SOURCE_DIR}/${main_cpp})
    add_executable ("${bin_prefix}${bin_name}" ${main_cpp} ${SRCS})
    target_link_libraries ("${bin_prefix}${bin_name}" m)
  else()
    message("file \"${main_cpp}\" does not exist. skip.")
  endif()
ENDFOREACH()
