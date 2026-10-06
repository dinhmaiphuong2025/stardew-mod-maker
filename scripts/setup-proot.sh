#!/usr/bin/env bash
# ==============================================================================
# Script cấu hình môi trường bên trong PRoot Ubuntu (glibc aarch64)
# Tuân thủ UI Style Shell (ui-style-shell) - Ký tự Braille & Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
elif [ -f "/root/stardew-env/scripts/ui.sh" ]; then
    source "/root/stardew-env/scripts/ui.sh"
fi

# 1. Cập nhật hệ thống và kích hoạt universe để cài đặt đầy đủ gói
export DEBIAN_FRONTEND=noninteractive

if [ -f /etc/apt/sources.list.d/ubuntu.sources ]; then
    sed -i 's/Components: main/Components: main universe/g' /etc/apt/sources.list.d/ubuntu.sources 2>/dev/null || true
fi
if [ -f /etc/apt/sources.list ]; then
    sed -i 's/main$/main universe/g' /etc/apt/sources.list 2>/dev/null || true
fi

apt-get update -y >/dev/null 2>&1 || true
apt-get install -y curl wget git jq zip unzip nano sudo python3 ca-certificates libicu-dev >/dev/null 2>&1 || \
    apt-get install -y curl wget git sudo ca-certificates >/dev/null 2>&1 || true

# 2. Cài đặt .NET 10.0 SDK vào thư mục dùng chung /opt/dotnet
mkdir -p /opt/dotnet
if [ ! -f /opt/dotnet/dotnet ]; then
    curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh >/dev/null 2>&1 || \
        wget -qO /tmp/dotnet-install.sh https://dot.net/v1/dotnet-install.sh >/dev/null 2>&1 || true

    if [ -f /tmp/dotnet-install.sh ]; then
        bash /tmp/dotnet-install.sh --channel 10.0 --install-dir /opt/dotnet >/dev/null 2>&1 || \
            bash /tmp/dotnet-install.sh --channel 9.0 --install-dir /opt/dotnet >/dev/null 2>&1 || true
        rm -f /tmp/dotnet-install.sh
    fi
fi

# Liên kết toàn cục
if [ -f /opt/dotnet/dotnet ]; then
    ln -sf /opt/dotnet/dotnet /usr/local/bin/dotnet
fi

# Cấu hình biến môi trường hệ thống cho tất cả người dùng
cat << 'EOF' > /etc/profile.d/dotnet.sh
export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF

export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1

# 3. Lưu trữ template toàn cục và cài đặt các công cụ CLI
TEMPLATE_STORE="/usr/local/share/stardew-template"
mkdir -p "$TEMPLATE_STORE"

if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    cp -f "$SCRIPT_DIR/ui.sh" /usr/local/bin/ui.sh
    chmod +x /usr/local/bin/ui.sh
fi

if [ -f "$SCRIPT_DIR/stardew-mod.sh" ]; then
    cp -f "$SCRIPT_DIR/stardew-mod.sh" /usr/local/bin/stardew-mod
    chmod +x /usr/local/bin/stardew-mod
fi

if [ -f "$SCRIPT_DIR/init-user.sh" ]; then
    cp -f "$SCRIPT_DIR/init-user.sh" /usr/local/bin/init-user.sh
    chmod +x /usr/local/bin/init-user.sh
fi

if [ -d "/root/stardew-env" ]; then
    cp -rf /root/stardew-env/templates "$TEMPLATE_STORE/" 2>/dev/null || true
    cp -rf /root/stardew-env/docs "$TEMPLATE_STORE/" 2>/dev/null || true
    cp -f /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$TEMPLATE_STORE/" 2>/dev/null || true
fi

exit 0
