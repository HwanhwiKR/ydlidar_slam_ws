#!/bin/bash
set -e

echo -e "\n[START][07] Split build for low-RAM system\n"

source /opt/ros/humble/setup.bash
source ~/ydlidar_slam_ws/install/setup.bash 2>/dev/null || true

WS=~/ydlidar_slam_ws
cd $WS

# --------------------------------------------------
# 1. ydlidar_sdk (plain cmake)
# --------------------------------------------------
echo -e "\n[STEP 1] Build ydlidar_sdk\n"
colcon build \
  --packages-select ydlidar_sdk \
  --symlink-install \
  --parallel-workers 1 \
  --event-handlers console_direct+

source install/setup.bash

# --------------------------------------------------
# 2. ydlidar_ros2_driver
# --------------------------------------------------
echo -e "\n[STEP 2] Build ydlidar_ros2_driver\n"
colcon build \
  --packages-select ydlidar_ros2_driver \
  --symlink-install \
  --parallel-workers 1 \
  --event-handlers console_direct+

source install/setup.bash

# --------------------------------------------------
# 3. rf2o_laser_odometry
# --------------------------------------------------
echo -e "\n[STEP 3] Build rf2o_laser_odometry\n"
colcon build \
  --packages-select rf2o_laser_odometry \
  --symlink-install \
  --parallel-workers 1 \
  --event-handlers console_direct+

source install/setup.bash

# --------------------------------------------------
# 4. 나머지 전체 빌드
# --------------------------------------------------
echo -e "\n[STEP 4] Build remaining packages\n"
colcon build \
  --symlink-install \
  --parallel-workers 1 \
  --event-handlers console_direct+

echo -e "\n[DONE ][07] Split build completed safely ✅\n"
