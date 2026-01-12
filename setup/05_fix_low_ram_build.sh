#!/bin/bash
set -e

echo "=== [04] Low RAM Build Fix (Raspberry Pi) ==="

# --------------------------------------------------
# 1. 메모리 상태 확인
# --------------------------------------------------
echo "[INFO] Current memory status"
free -h

# --------------------------------------------------
# 2. zram 비활성화 (Ubuntu Server / Desktop)
# --------------------------------------------------
if systemctl is-active --quiet zram-config; then
  echo "[INFO] Disabling zram-config"
  sudo systemctl disable --now zram-config
fi

if systemctl is-active --quiet zram; then
  echo "[INFO] Disabling zram"
  sudo systemctl disable --now zram
fi

# --------------------------------------------------
# 3. Swap 파일 생성 (4GB)
# --------------------------------------------------
SWAPFILE="/swapfile"

if swapon --show | grep -q "$SWAPFILE"; then
  echo "[INFO] Swapfile already enabled"
else
  echo "[INFO] Creating 4GB swapfile"

  sudo fallocate -l 4G $SWAPFILE || sudo dd if=/dev/zero of=$SWAPFILE bs=1M count=4096
  sudo chmod 600 $SWAPFILE
  sudo mkswap $SWAPFILE
  sudo swapon $SWAPFILE

  echo "$SWAPFILE none swap sw 0 0" | sudo tee -a /etc/fstab
fi

# --------------------------------------------------
# 4. OOM Killer 완화 설정
# --------------------------------------------------
echo "[INFO] Tuning kernel memory settings"

sudo sysctl -w vm.swappiness=60
sudo sysctl -w vm.vfs_cache_pressure=50

# 영구 적용
sudo tee /etc/sysctl.d/99-ros-lowram.conf <<EOF
vm.swappiness=60
vm.vfs_cache_pressure=50
EOF

# --------------------------------------------------
# 5. 빌드 병렬 제한 안내
# --------------------------------------------------
echo
echo "=================================================="
echo "IMPORTANT:"
echo "빌드 시 반드시 병렬 제한을 사용하세요."
echo
echo "권장:"
echo "  colcon build --parallel-workers 1"
echo
echo "=================================================="

# --------------------------------------------------
# 6. 최종 메모리 상태
# --------------------------------------------------
echo "[INFO] Final memory status"
free -h

echo "=== [04] Low RAM Build Fix completed ==="
