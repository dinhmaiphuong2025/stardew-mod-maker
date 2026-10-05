#!/usr/bin/env bash
# ==============================================================================
# Script cấu hình môi trường bên trong PRoot Ubuntu (glibc aarch64)
# Tuân thủ UI Style Shell (ui-style-shell) - Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
elif [ -f "/root/stardew-env/scripts/ui.sh" ]; then
    source "/root/stardew-env/scripts/ui.sh"
fi

banner "CẤU HÌNH PROOT UBUNTU" "Thiết lập môi trường C# & .NET 10 SDK"

# 1. Cập nhật hệ thống
print_info "Cập nhật kho gói Ubuntu và cài đặt các công cụ nền tảng..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget git jq zip unzip nano sudo python3 ca-certificates libicu-dev nodejs npm >/dev/null 2>&1
print_success "Các gói công cụ hệ thống đã sẵn sàng."

# 2. Cài đặt .NET 10.0 SDK vào thư mục dùng chung /opt/dotnet
print_info "Đang cài đặt .NET 10.0 SDK (Microsoft Official aarch64)..."
mkdir -p /opt/dotnet
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0 --install-dir /opt/dotnet >/dev/null 2>&1

# Liên kết toàn cục
ln -sf /opt/dotnet/dotnet /usr/local/bin/dotnet

# Cấu hình biến môi trường hệ thống cho tất cả người dùng
cat << 'EOF' > /etc/profile.d/dotnet.sh
export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1
EOF

export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:$DOTNET_ROOT
export DOTNET_CLI_TELEMETRY_OPTOUT=1

if /opt/dotnet/dotnet --version >/dev/null 2>&1; then
    DOTNET_VER=$(/opt/dotnet/dotnet --version)
    print_success ".NET SDK hoạt động tốt (Phiên bản $DOTNET_VER)."
else
    print_error "Không thể khởi động .NET SDK. Vui lòng kiểm tra lại kết nối mạng."
fi

# 3. Lưu trữ template toàn cục và cài đặt các công cụ CLI
TEMPLATE_STORE="/usr/local/share/stardew-template"
mkdir -p "$TEMPLATE_STORE"

if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    cp "$SCRIPT_DIR/ui.sh" /usr/local/bin/ui.sh
    chmod +x /usr/local/bin/ui.sh
fi

if [ -f "$SCRIPT_DIR/stardew-mod.sh" ]; then
    cp "$SCRIPT_DIR/stardew-mod.sh" /usr/local/bin/stardew-mod
    chmod +x /usr/local/bin/stardew-mod
fi

if [ -f "$SCRIPT_DIR/init-user.sh" ]; then
    cp "$SCRIPT_DIR/init-user.sh" /usr/local/bin/init-user.sh
    chmod +x /usr/local/bin/init-user.sh
fi

if [ -d "/root/stardew-env" ]; then
    cp -r /root/stardew-env/templates "$TEMPLATE_STORE/" 2>/dev/null || true
    cp /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$TEMPLATE_STORE/" 2>/dev/null || true
fi

# 4. Cấu hình kiểm tra tạo user khi đăng nhập root lần đầu
cat << 'EOF' >> /root/.bashrc

# Kiểm tra và khởi tạo user sudo lần đầu tiên
if [ ! -f /etc/stardew-user-created ] && [ -f /usr/local/bin/init-user.sh ]; then
    /usr/local/bin/init-user.sh
fi

# Tự động chuyển sang tài khoản người dùng mặc định nếu có
if [ -f /etc/stardew-default-user ]; then
    SD_USER=$(cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
    if [ "$USER" = "root" ] && [ -n "$SD_USER" ] && id "$SD_USER" >/dev/null 2>&1; then
        exec su - "$SD_USER"
    fi
fi
EOF

print_success "Cấu hình môi trường PRoot hoàn tất."
