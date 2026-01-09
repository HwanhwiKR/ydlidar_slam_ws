#!/bin/bash
set -e

# ---- apt 상태 복구 ----
sudo dpkg --configure -a || true
sudo apt --fix-broken install -y || true

echo "===== ROS2 Humble Setup (Ubuntu 22.04 Jammy) ====="

# --------------------------------------------------
# 0. 기본 정보 확인
# --------------------------------------------------
sudo apt update
sudo apt install -y lsb-release

lsb_release -a
uname -m

# --------------------------------------------------
# 1. 기본 빌드 / Python 환경
# --------------------------------------------------
sudo apt install -y \
  git curl wget build-essential cmake pkg-config \
  python3-pip python3-venv

# --------------------------------------------------
# 2. locale 설정
# --------------------------------------------------
sudo apt install -y locales
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# --------------------------------------------------
# 3. universe 저장소 활성화
# --------------------------------------------------
sudo apt install -y software-properties-common
sudo add-apt-repository universe
sudo apt update

# --------------------------------------------------
# 4. ROS2 저장소 추가 (Jammy)
# --------------------------------------------------
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
# 5. ROS2 Humble 설치
# --------------------------------------------------
sudo apt install -y ros-humble-desktop

# --------------------------------------------------
# 6. rosdep 충돌 제거 + ROS 개발 도구
# --------------------------------------------------
echo ">> Fix rosdep conflicts"

# 구버전 rosdep 제거 (있어도 에러 안 나게)
sudo apt remove -y python3-rosdep python3-rosdep-modules || true

# Jammy 기준 정답 패키지
sudo apt install -y \
  python3-rosdep2 \
  ros-dev-tools

# --------------------------------------------------
# 7. ROS 환경 설정
# --------------------------------------------------
source /opt/ros/humble/setup.bash
if ! grep -q "source /opt/ros/humble/setup.bash" ~/.bashrc; then
  echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc
fi

# --------------------------------------------------
# 8. rosdep 초기화
# --------------------------------------------------
sudo rosdep init || true
rosdep update

# --------------------------------------------------
# 9. 추가 라이브러리 (ydlidar / rf2o / slam)
# --------------------------------------------------
sudo apt install -y libeigen3-dev libomp-dev

sudo apt install -y \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs

# --------------------------------------------------
# 완료
# --------------------------------------------------
echo "===== ✅ ROS2 Humble 기본 설치 완료 ====="
echo "새 터미널을 열거나 다음 명령 실행:"
echo "source ~/.bashrc"
