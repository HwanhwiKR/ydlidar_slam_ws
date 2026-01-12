# Copyright(c) 2020 eaibot limited.
cmake_minimum_required(VERSION 3.5)
project(ydlidar_ros2_driver LANGUAGES C CXX)

################## C++ 표준 설정 ##################
if(NOT CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 14)
endif()

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

################## ROS2 패키지 ##################
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(rmw REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(visualization_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(std_srvs REQUIRED)

################## YDLIDAR SDK ##################
# SDK를 내부 서브디렉토리 라이브러리로 포함
add_subdirectory(
  ${CMAKE_CURRENT_SOURCE_DIR}/../YDLidar-SDK
  ydlidar_sdk_build
)

################## Node 실행 파일 ##################
add_executable(${PROJECT_NAME}_node
  src/${PROJECT_NAME}_node.cpp
)

ament_target_dependencies(${PROJECT_NAME}_node
  rclcpp
  sensor_msgs
  visualization_msgs
  geometry_msgs
  std_srvs
)

# SDK 라이브러리 링크
target_link_libraries(${PROJECT_NAME}_node
  ydlidar_sdk
)

# ❗ 핵심 수정 포인트
# SDK가 export하는 include 디렉토리를 타겟에 연결
target_include_directories(${PROJECT_NAME}_node PRIVATE
  ${PROJECT_SOURCE_DIR}/include
)

################## Client 실행 파일 ##################
add_executable(${PROJECT_NAME}_client
  src/${PROJECT_NAME}_client.cpp
)

ament_target_dependencies(${PROJECT_NAME}_client
  rclcpp
  sensor_msgs
  visualization_msgs
  geometry_msgs
  std_srvs
)

target_link_libraries(${PROJECT_NAME}_client
  ydlidar_sdk
)

target_include_directories(${PROJECT_NAME}_client PRIVATE
  ${PROJECT_SOURCE_DIR}/include
)

################## Install ##################
install(TARGETS
  ${PROJECT_NAME}_node
  ${PROJECT_NAME}_client
  DESTINATION lib/${PROJECT_NAME}
)

install(DIRECTORY
  launch
  params
  startup
  config
  DESTINATION share/${PROJECT_NAME}
)

################## Test ##################
if(BUILD_TESTING)
  find_package(ament_lint_auto REQUIRED)
  ament_lint_auto_find_test_dependencies()
endif()

ament_package()
