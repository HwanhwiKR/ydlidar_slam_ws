#!/bin/bash
set -e

echo "===== 0. 기본 정보 ====="
sudo apt update
sudo apt install -y lsb-release
lsb_release -a
uname -m

echo "===== 1. 기본 빌드 / Python ====="
sudo apt install -y \
  git curl wget build-essential cmake pkg-config \
  python3-pip python3-venv

echo "===== 2. locale 설정 ====="
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

echo "===== 3. universe 저장소 ====="
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update

echo "===== 4. ROS2 저장소 추가 ====="
sudo apt install -y curl gnupg lsb-release
sudo mkdir -p /etc/apt/keyrings

curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key \
| sudo gpg --dearmor -o /etc/apt/keyrings/ros-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/ros-archive-keyring.gpg] \
http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/ros2.list > /dev/null

sudo apt update

echo "===== 5. ROS2 Humble ====="
sudo apt install -y ros-humble-desktop

echo "===== 6. ROS 개발 도구 ====="
sudo apt install -y \
  python3-rosdep2 \
  colcon-common-extensions \
  ros-dev-tools

echo "===== 7. ROS 환경 설정 ====="
if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc; then
  echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi
source /opt/ros/humble/setup.bash

echo "===== 8. rosdep 초기화 ====="
sudo rosdep init || true
rosdep update

echo "===== 9. 추가 라이브러리 ====="
sudo apt install -y libeigen3-dev libomp-dev

echo "===== 10. tf2 ====="
sudo apt install -y \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs

echo "===== 완료 ====="
echo "새 터미널을 열거나 source ~/.bashrc 실행하세요"
