#!/bin/bash
set -e
set -o pipefail

# ==================================================
# 완전 비대화형 설치 환경 (ENTER / 질문 / pager 차단)
# ==================================================
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export PAGER=cat
export TERM=dumb

APT_OPTS="-y \
  -o Dpkg::Options::=--force-confdef \
  -o Dpkg::Options::=--force-confold"

echo "===== ROS2 Humble Full Setup (Ubuntu 22.04 Jammy) ====="

# --------------------------------------------------
# 0. apt lock / 자동 업데이트 완전 차단
# --------------------------------------------------
echo ">> Stopping auto apt services"
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
sudo apt-get update
sudo apt-get install $APT_OPTS lsb-release
lsb_release -a
uname -m

# --------------------------------------------------
# 2. 기본 빌드 / Python 환경
# --------------------------------------------------
echo ">> Base build & python"
sudo apt-get install $APT_OPTS \
  git curl wget build-essential cmake pkg-config \
  python3-pip python3-venv

# --------------------------------------------------
# 3. locale 설정 (ENTER 요구 원천 차단)
# --------------------------------------------------
echo ">> Locale setup"
sudo apt-get install $APT_OPTS locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# --------------------------------------------------
# 4. universe 저장소
# --------------------------------------------------
echo ">> Enable universe repository"
sudo apt-get install $APT_OPTS software-properties-common
sudo add-apt-repository -y universe
sudo apt-get update

# --------------------------------------------------
# 5. ROS2 저장소 추가 (Jammy 고정)
# --------------------------------------------------
echo ">> Add ROS2 repository"
sudo apt-get install $APT_OPTS curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg

sudo rm -f /etc/apt/sources.list.d/ros2.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu jammy main" \
| sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt-get update

# --------------------------------------------------
# 6. ROS2 Humble 설치 (ENTER 가장 많이 뜨는 구간)
# --------------------------------------------------
echo ">> Install ROS2 Humble Desktop"
sudo apt-get install $APT_OPTS ros-humble-desktop

# --------------------------------------------------
# 7. ROS 개발 도구 (Jammy 정답)
# --------------------------------------------------
echo ">> Install ROS dev tools (colcon, rosdep)"
sudo apt-get install $APT_OPTS \
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
sudo apt-get install $APT_OPTS libeigen3-dev libomp-dev

sudo apt-get install $APT_OPTS \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs

# --------------------------------------------------
# 완료
# --------------------------------------------------
echo "===== ✅ ROS2 Humble setup completed successfully ====="
echo "새 터미널을 열거나 다음 명령 실행:"
echo "source ~/.bashrc"
