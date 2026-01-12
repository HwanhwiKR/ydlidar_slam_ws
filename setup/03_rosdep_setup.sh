#!/bin/bash
set -e

echo -e "\n[START][03] rosdep setup\n"

sudo apt install -y python3-rosdep

if [ ! -f /etc/ros/rosdep/sources.list.d/20-default.list ]; then
  sudo rosdep init
fi

rosdep update

echo -e "\n[DONE ][03] rosdep setup completed ✅\n"
