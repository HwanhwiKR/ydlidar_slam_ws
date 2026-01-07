#!/bin/bash
set -e
set -o pipefail


# 비대화형 설치 (엔터/질문 스킵)
export DEBIAN_FRONTEND=noninteractive


echo "===== ROS2 Humble Full Setup (Ubuntu 22.04 Jammy) ====="

# --------------------------------------------------
# 0. apt lock / 자동 업데이트 처리
# --------------------------------------------------
echo ">> Stopping auto apt services (if any)"
sudo systemctl stop unattended-upgrades || true
sudo systemctl stop apt-daily.service || true
sudo systemctl stop apt-daily-upgrade.service || true

wait_for_apt() {
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    echo "⏳ Waiting for apt lock..."
    sleep 5
  done
}
wait_for_apt

# --------------------------------------------------
# 1. 기본 정보
# --------------------------------------------------
echo ">> System info"
sudo apt update
sudo apt install -y lsb-release
lsb_release -a
uname -m

# --------------------------------------------------
# 2. 기본 빌드 / Python 환경
# --------------------------------------------------
echo ">> Base build & python"
sudo apt install -y \
  git curl wget build-essential cmake pkg-config \
  python3-pip python3-venv

# --------------------------------------------------
# 3. locale 설정
# --------------------------------------------------
echo ">> Locale setup"
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# --------------------------------------------------
# 4. universe 저장소
# --------------------------------------------------
echo ">> Enable universe repository"
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update

# --------------------------------------------------
# 5. ROS2 저장소 추가 (Jammy 고정)
# --------------------------------------------------
echo ">> Add ROS2 repository"
sudo apt install -y curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg

sudo rm -f /etc/apt/sources.list.d/ros2.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu jammy main" \
| sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update

# --------------------------------------------------
# 6. ROS2 Humble 설치
# --------------------------------------------------
echo ">> Install ROS2 Humble Desktop"
sudo apt install -y ros-humble-desktop

# --------------------------------------------------
# 7. ROS 개발 도구 (Jammy 정답)
# --------------------------------------------------
echo ">> Install ROS dev tools (colcon, rosdep)"
sudo apt install -y \
  python3-rosdep2 \
  ros-dev-tools

# --------------------------------------------------
# 8. ROS 환경 설정
# --------------------------------------------------
echo ">> ROS environment setup"
if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc; then
  echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi
source /opt/ros/humble/setup.bash

# --------------------------------------------------
# 9. rosdep 초기화
# --------------------------------------------------
echo ">> rosdep init/update"
sudo rosdep init || true
rosdep update

# --------------------------------------------------
# 10. 추가 라이브러리 (ydlidar / rf2o / slam)
# --------------------------------------------------
echo ">> Extra libraries"
sudo apt install -y libeigen3-dev libomp-dev

sudo apt install -y \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs

# --------------------------------------------------
# 완료
# --------------------------------------------------
echo "===== ✅ ROS2 Humble setup completed successfully ====="
echo "새 터미널을 열거나 다음 명령 실행:"
echo "source ~/.bashrc"
