#!/bin/bash
set -e

echo "=== [03] rosdep setup (Jammy / ROS 2 Humble safe) ==="

# --------------------------------------------------
# 1. rosdep 설치 확인
# --------------------------------------------------
sudo apt update
sudo apt install -y python3-rosdep

# --------------------------------------------------
# 2. 오래된 rosdep source 제거 (Jammy 호환성 문제 방지)
# --------------------------------------------------
ROSDEP_SRC_DIR="/etc/ros/rosdep/sources.list.d"
ROSDEP_DEFAULT_FILE="${ROSDEP_SRC_DIR}/20-default.list"

if [ -f "$ROSDEP_DEFAULT_FILE" ]; then
  echo "[INFO] Removing old rosdep source: $ROSDEP_DEFAULT_FILE"
  sudo rm -f "$ROSDEP_DEFAULT_FILE"
fi

# --------------------------------------------------
# 3. rosdep 초기화 (이미 되어 있으면 스킵)
# --------------------------------------------------
if [ ! -d "$ROSDEP_SRC_DIR" ] || [ -z "$(ls -A $ROSDEP_SRC_DIR 2>/dev/null)" ]; then
  echo "[INFO] Initializing rosdep..."
  sudo rosdep init
else
  echo "[INFO] rosdep already initialized, skipping init"
fi

# --------------------------------------------------
# 4. rosdep 업데이트
# --------------------------------------------------
echo "[INFO] Updating rosdep database..."
rosdep update

echo "=== [03] rosdep setup completed successfully ==="
