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

# 2. Cài đặt .NET 10.0 SDK
print_info "Dang cai dat .NET 10.0 SDK (Microsoft Official aarch64)..."
mkdir -p /root/.dotnet
curl -sSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 10.0 --install-dir /root/.dotnet >/dev/null 2>&1

# Cấu hình biến môi trường
if ! grep -q "DOTNET_ROOT" /root/.bashrc 2>/dev/null; then
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

if /root/.dotnet/dotnet --version >/dev/null 2>&1; then
    DOTNET_VER=$(/root/.dotnet/dotnet --version)
    print_success ".NET SDK hoat dong tot (Phien ban $DOTNET_VER)."
else
    print_error "Khong the khoi dong .NET SDK. Vui long kiem tra lai ket noi mang."
fi

# 3. Thiết lập thư mục workspace & CLI
WORKSPACE="/root/stardew-workspace"
mkdir -p "$WORKSPACE"
mkdir -p "$WORKSPACE/lib"
mkdir -p "$WORKSPACE/mods"
mkdir -p "$WORKSPACE/scripts"

# Lưu ui.sh vào /usr/local/bin và workspace
if [ -f "$SCRIPT_DIR/ui.sh" ]; then
    cp "$SCRIPT_DIR/ui.sh" /usr/local/bin/ui.sh
    cp "$SCRIPT_DIR/ui.sh" "$WORKSPACE/scripts/ui.sh"
    chmod +x /usr/local/bin/ui.sh
fi

# Sao chép template và stardew-mod CLI
if [ -d "/root/stardew-env" ]; then
    cp -r /root/stardew-env/templates "$WORKSPACE/"
    cp -r /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$WORKSPACE/"
    cp /root/stardew-env/scripts/stardew-mod.sh /usr/local/bin/stardew-mod
    chmod +x /usr/local/bin/stardew-mod
fi

# 4. Banner chào mừng trong .bashrc
cat << 'EOF' >> /root/.bashrc

if [ -f /usr/local/bin/ui.sh ]; then
    source /usr/local/bin/ui.sh
    clear_screen
    banner "STARDEW MOD VIBECODING" "Khong gian sang tao Mod Cinderbox Android"
    print_info "Go 'stardew-mod' de mo Menu dieu khien."
    print_line
fi
cd /root/stardew-workspace
EOF

print_success "Cau hinh moi truong PRoot hoan tat."
