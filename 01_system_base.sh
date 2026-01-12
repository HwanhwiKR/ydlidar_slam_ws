#!/bin/bash
set -e

echo "=== [01] System base setup ==="

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  lsb-release \
  git curl wget \
  build-essential cmake pkg-config \
  python3-pip python3-venv locales

# locale
sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

# universe
sudo apt install -y software-properties-common
sudo add-apt-repository -y universe
