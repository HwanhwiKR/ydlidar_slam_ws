#!/bin/bash
set -e

echo "=== [04] Project dependencies ==="

sudo apt install -y \
  libeigen3-dev \
  libomp-dev \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs
