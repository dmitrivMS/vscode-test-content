cmake_minimum_required(VERSION 3.20)
project(ImageProcessor VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

find_package(OpenCV 4.5 REQUIRED COMPONENTS core imgproc highgui)
find_package(Threads REQUIRED)

add_library(imgcore STATIC
    src/image_loader.cpp
    src/filters.cpp
    src/transform.cpp
)
target_include_directories(imgcore PUBLIC ${CMAKE_SOURCE_DIR}/include)
target_link_libraries(imgcore PUBLIC ${OpenCV_LIBS})

add_executable(imgproc src/main.cpp)
target_link_libraries(imgproc PRIVATE imgcore Threads::Threads)

enable_testing()
add_subdirectory(tests)
