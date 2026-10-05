#!/usr/bin/env bash
# ==============================================================================
# Script cấu hình môi trường bên trong PRoot Ubuntu (glibc aarch64)
# Tuân thủ UI Style Shell (ui-style-shell)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
elif [ -f "/root/stardew-env/scripts/ui.sh" ]; then
    source "/root/stardew-env/scripts/ui.sh"
else
    print_line() { printf "\033[90m─────────────────────────────────────────────────────────────\033[0m\n"; }
    print_info() { printf "\033[1;34mℹ %s\033[0m\n" "$1"; }
    print_success() { printf "\033[1;32m✓ %s\033[0m\n" "$1"; }
    print_warning() { printf "\033[1;33m⚠ %s\033[0m\n" "$1"; }
    print_error() { printf "\033[1;31m✗ %s\033[0m\n" "$1"; }
    banner() {
        printf "      \033[1;37m%s\033[0m\n" "$1"
        [ -n "$2" ] && printf "      \033[90m%s\033[0m\n" "$2"
        print_line
    }
    print_box() {
        local len=${#1} border=""
        for ((i=0; i<len+2; i++)); do border="${border}─"; done
        printf "  \033[90m┌%s┐\033[0m\n  \033[90m│\033[0m %s \033[90m│\033[0m\n  \033[90m└%s┘\033[0m\n" "$border" "$1" "$border"
    }
fi

banner "STARDEW PROOT SETUP" "Thiet lap moi truong C# & .NET 10 SDK"

# 1. Cập nhật hệ thống
print_info "Cap nhat kho goi Ubuntu va cai dat cong cu can thiet..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y >/dev/null 2>&1
apt-get install -y curl wget git jq zip unzip nano sudo python3 ca-certificates libicu-dev >/dev/null 2>&1
print_success "Cac goi he thong da san sang."

# 2. Cài đặt .NET 10.0 SDK vào thư mục dùng chung /opt/dotnet
print_info "Dang cai dat .NET 10.0 SDK (Microsoft Official aarch64)..."
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
    print_success ".NET SDK hoat dong tot (Phien ban $DOTNET_VER)."
else
    print_error "Khong the khoi dong .NET SDK. Vui long kiem tra lai ket noi mang."
fi

# 3. Cài đặt các kịch bản và công cụ hệ thống
WORKSPACE="/root/stardew-workspace"
mkdir -p "$WORKSPACE/lib" "$WORKSPACE/mods" "$WORKSPACE/scripts"

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
    cp -r /root/stardew-env/templates "$WORKSPACE/"
    cp -r /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$WORKSPACE/"
fi

# 4. Cấu hình kiểm tra tạo user khi đăng nhập root lần đầu
cat << 'EOF' >> /root/.bashrc

# Kiem tra va khoi tao user sudo lan dau tien
if [ ! -f /etc/stardew-user-created ] && [ -f /usr/local/bin/init-user.sh ]; then
    /usr/local/bin/init-user.sh
fi

# Tu dong chuyen sang tai khoan nguoi dung mac dinh neu co
if [ -f /etc/stardew-default-user ]; then
    SD_USER=$(cat /etc/stardew-default-user)
    if [ "$USER" = "root" ] && [ -n "$SD_USER" ] && id "$SD_USER" >/dev/null 2>&1; then
        exec su - "$SD_USER"
    fi
fi
EOF

print_success "Cau hinh moi truong PRoot hoan tat."
