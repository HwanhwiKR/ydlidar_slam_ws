cmake_minimum_required(VERSION 3.5)
project(ydlidar_ros2_driver LANGUAGES C CXX)

################## C++ 표준 ##################
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

################## ROS2 ##################
find_package(ament_cmake REQUIRED)
find_package(rclcpp REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(visualization_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)
find_package(std_srvs REQUIRED)

################## YDLIDAR SDK ##################
# 🔥 반드시 외부 패키지로 찾는다
find_package(ydlidar_sdk REQUIRED)

################## Node ##################
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

target_link_libraries(${PROJECT_NAME}_node
  ydlidar::ydlidar_sdk
)

################## Client ##################
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
  ydlidar::ydlidar_sdk
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
