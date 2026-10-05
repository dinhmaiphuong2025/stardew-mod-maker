#!/usr/bin/env bash
# ==============================================================================
# Script cấu hình môi trường bên trong PRoot Ubuntu (glibc aarch64)
# Được gọi tự động từ install.sh
# ==============================================================================

set -e

# Màu sắc
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "\n${CYAN}[PRoot] Đang cập nhật gói hệ thống Ubuntu...${NC}"
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y curl wget git jq zip unzip nano sudo python3 ca-certificates libicu-dev

# 1. Cài đặt .NET 10.0 SDK qua script chính thức của Microsoft
echo -e "\n${BLUE}[PRoot] Đang cài đặt .NET 10.0 SDK (chuẩn Cinderbox SMAPI)...${NC}"
mkdir -p /root/.dotnet
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0 --install-dir /root/.dotnet

# Thêm biến môi trường .NET vào bashrc
if ! grep -q "DOTNET_ROOT" /root/.bashrc; then
    cat << 'EOF' >> /root/.bashrc

# .NET SDK Configuration
export DOTNET_ROOT=/root/.dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF
fi

export DOTNET_ROOT=/root/.dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# Kiểm tra dotnet đã hoạt động chưa
if /root/.dotnet/dotnet --version >/dev/null 2>&1; then
    DOTNET_VER=$(/root/.dotnet/dotnet --version)
    echo -e "${GREEN}✓ .NET SDK đã sẵn sàng: phiên bản $DOTNET_VER${NC}"
else
    echo -e "${RED}[!] Không thể khởi động .NET SDK. Vui lòng kiểm tra lại kết nối mạng!${NC}"
fi

# 2. Thiết lập thư mục làm việc chính
WORKSPACE="/root/stardew-workspace"
mkdir -p "$WORKSPACE"
mkdir -p "$WORKSPACE/lib"
mkdir -p "$WORKSPACE/mods"

# Sao chép template và bộ công cụ vào workspace
if [ -d "/root/stardew-env" ]; then
    cp -r /root/stardew-env/templates "$WORKSPACE/"
    cp -r /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$WORKSPACE/"
    cp /root/stardew-env/scripts/stardew-mod.sh /usr/local/bin/stardew-mod
    chmod +x /usr/local/bin/stardew-mod
fi

# 3. Tạo lời chào và chỉ dẫn mỗi khi vào container
cat << 'EOF' >> /root/.bashrc

# Welcome banner
echo -e "\033[0;36m===============================================================\033[0m"
echo -e "\033[0;32m   ★ MÔI TRƯỜNG VIBECODING STARDEW VALLEY CINDERBOX SẴN SÀNG ★  \033[0m"
echo -e "\033[0;36m===============================================================\033[0m"
echo -e "\033[1;33mCác lệnh hữu ích nhanh cho bạn:\033[0m"
echo -e "  \033[0;32mstardew-mod doctor\033[0m         -> Kiểm tra game files & Cinderbox"
echo -e "  \033[0;32mstardew-mod new <TenMod>\033[0m   -> Tạo một dự án mod mới trong 1 giây"
echo -e "  \033[0;32mstardew-mod build\033[0m          -> Biên dịch mod hiện tại"
echo -e "  \033[0;32mstardew-mod deploy\033[0m         -> Cài thẳng mod vào thư mục game"
echo -e "\033[0;36m===============================================================\033[0m\n"
cd /root/stardew-workspace
EOF

echo -e "${GREEN}✓ Hoàn tất cấu hình bên trong PRoot Ubuntu!${NC}"
