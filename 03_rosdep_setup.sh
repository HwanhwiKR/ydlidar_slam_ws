#!/bin/bash
set -e

echo "=== [03] rosdep setup ==="

sudo apt install -y python3-rosdep

if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi

rosdep update
