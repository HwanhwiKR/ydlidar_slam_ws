#!/bin/bash
set -e

echo "=== [05] Build workspace ==="

source /opt/ros/humble/setup.bash

WS=~/ydlidar_slam_ws

if [ ! -d "$WS/src" ]; then
  echo "[ERROR] $WS/src not found"
  exit 1
fi

cd $WS

rosdep install --from-paths src --ignore-src -r -y

colcon build \
  --symlink-install \
  --parallel-workers $(nproc) \
  --event-handlers console_direct+

if ! grep -q "$WS/install/setup.bash" ~/.bashrc; then
  echo "source $WS/install/setup.bash" >> ~/.bashrc
fi
