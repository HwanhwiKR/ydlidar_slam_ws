#!/bin/bash
set -e

echo -e "\n[START][01] System base setup\n"

sudo apt update
sudo apt upgrade -y

sudo apt install -y \
  lsb-release \
  git curl wget \
  build-essential cmake pkg-config \
  python3-pip python3-venv locales

sudo locale-gen en_US en_US.UTF-8
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
export LANG=en_US.UTF-8

sudo apt install -y software-properties-common
sudo add-apt-repository -y universe

echo -e "\n[DONE ][01] System base setup completed ✅\n"
