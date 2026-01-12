#!/bin/bash
set -e

echo -e "\n[START][06] Build ydlidar_slam_ws\n"

source /opt/ros/humble/setup.bash

WS=~/ydlidar_slam_ws

if [ ! -d "$WS/src" ]; then
  echo "[ERROR][06] $WS/src not found"
  exit 1
fi

cd $WS

echo "[INFO][06] Installing rosdep dependencies"
rosdep install --from-paths src --ignore-src -r -y

# --------------------------------------------------
# 병렬 빌드 수 제한 (RAM 보호)
# --------------------------------------------------
CORES=$(nproc)
if [ "$CORES" -ge 4 ]; then
  WORKERS=1
else
  WORKERS=1
fi

echo "[INFO][06] Using parallel-workers = $WORKERS"

colcon build \
  --symlink-install \
  --parallel-workers $WORKERS \
  --event-handlers console_direct+

# --------------------------------------------------
# 환경 자동 등록
# --------------------------------------------------
if ! grep -q "$WS/install/setup.bash" ~/.bashrc; then
  echo "source $WS/install/setup.bash" >> ~/.bashrc
fi

echo -e "\n[DONE ][06] Workspace build completed ✅\n"
