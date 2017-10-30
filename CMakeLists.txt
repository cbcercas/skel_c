cmake_minimum_required(VERSION 3.0)
set(NAME skell)
project($(NAME))

set(CMAKE_CXX_STANDARD 11)
set (CMAKE_C_FLAGS "-g -Wall -Werror -Wextra")

set(SOURCE_FILES
				srcs/main.c
		)

include_directories(includes)

add_executable($(NAME) ${SOURCE_FILES})
