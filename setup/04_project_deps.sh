#!/bin/bash
set -e

echo -e "\n[START][04] Project dependencies (Eigen / TF2)\n"

sudo apt install -y \
  libeigen3-dev \
  libomp-dev \
  ros-humble-tf2 \
  ros-humble-tf2-ros \
  ros-humble-tf2-geometry-msgs

echo -e "\n[DONE ][04] Project dependencies installed ✅\n"
