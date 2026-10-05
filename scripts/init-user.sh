#!/usr/bin/env bash
# ==============================================================================
# Script khởi tạo tài khoản người dùng sudo cho PRoot Ubuntu
# Tuân thủ UI Style Shell (ui-style-shell)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "/usr/local/bin/ui.sh" ]; then
    source "/usr/local/bin/ui.sh"
elif [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
else
    RESET='\033[0m'   BOLD='\033[1m'    GRAY='\033[90m'
    RED='\033[1;31m'  GREEN='\033[1;32m' YELLOW='\033[1;33m'
    BLUE='\033[1;34m' CYAN='\033[1;36m'  WHITE='\033[1;37m'
    clear_screen() { printf "\033[2J\033[H"; }
    print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
    print_prompt() { printf "${GREEN}❯ ${RESET}"; }
    print_success() { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
    print_error() { printf "${RED}✗ %s${RESET}\n" "$1"; }
    print_warning() { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
    print_info() { printf "${BLUE}ℹ %s${RESET}\n" "$1"; }
    banner() {
        printf "      ${BOLD}${WHITE}%s${RESET}\n" "$1"
        [ -n "$2" ] && printf "      ${GRAY}%s${RESET}\n" "$2"
        print_line
    }
    print_box() {
        local len=${#1} border=""
        for ((i=0; i<len+2; i++)); do border="${border}─"; done
        printf "  ${GRAY}┌%s┐${RESET}\n  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n  ${GRAY}└%s┘${RESET}\n" "$border" "$1" "$border"
    }
    confirm() {
        local resp
        printf "%s (y/N): " "$1"
        read -r resp
        case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
    }
fi

if [ -f "/etc/stardew-user-created" ]; then
    exit 0
fi

clear_screen
banner "KHOI TAO NGUOI DUNG" "Thiet lap tai khoan sudo cho Ubuntu PRoot"

print_info "Khoi dong lan dau: He thong can thiet lap mot tai khoan nguoi dung."
echo

# 1. Nhập tên người dùng
printf "Nhap ten nguoi dung (viet thuong khong dau, mac dinh: stardew): "
read -r INPUT_USER
INPUT_USER=$(echo "$INPUT_USER" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')
[ -z "$INPUT_USER" ] && INPUT_USER="stardew"

# 2. Nhập mật khẩu (tùy chọn)
printf "Nhap mat khau (nhan Enter de trong neu khong can dat mat khau): "
read -rs INPUT_PASS
echo

# 3. Hỏi tắt hỏi mật khẩu sudo
NOPASSWD=0
if confirm "Tat hoi mat khau khi su dung sudo? (Khuyen dung cho Termux)"; then
    NOPASSWD=1
fi

print_info "Dang tao nguoi dung '$INPUT_USER'..."

# Tạo user nếu chưa tồn tại
if ! id "$INPUT_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo,users "$INPUT_USER"
fi

# Thiết lập mật khẩu
if [ -n "$INPUT_PASS" ]; then
    echo "$INPUT_USER:$INPUT_PASS" | chpasswd
else
    passwd -d "$INPUT_USER" >/dev/null 2>&1 || true
fi

# Cấu hình sudoers
mkdir -p /etc/sudoers.d
if [ "$NOPASSWD" -eq 1 ] || [ -z "$INPUT_PASS" ]; then
    echo "$INPUT_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$INPUT_USER"
else
    echo "$INPUT_USER ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/$INPUT_USER"
fi
chmod 0440 "/etc/sudoers.d/$INPUT_USER"

# Thiết lập thư mục workspace cho user mới
USER_HOME="/home/$INPUT_USER"
USER_WORKSPACE="$USER_HOME/stardew-workspace"
mkdir -p "$USER_WORKSPACE"
mkdir -p "$USER_WORKSPACE/mods"
mkdir -p "$USER_WORKSPACE/lib"

if [ -d "/root/stardew-env/templates" ]; then
    cp -r /root/stardew-env/templates "$USER_WORKSPACE/"
elif [ -d "/root/stardew-workspace/templates" ]; then
    cp -r /root/stardew-workspace/templates "$USER_WORKSPACE/"
fi

if [ -f "/root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md" ]; then
    cp /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$USER_WORKSPACE/"
elif [ -f "/root/stardew-workspace/VIBECODE_PROMPT_TEMPLATE.md" ]; then
    cp /root/stardew-workspace/VIBECODE_PROMPT_TEMPLATE.md "$USER_WORKSPACE/"
fi

# Thêm banner khởi động vào .bashrc của user
cat << 'EOF' >> "$USER_HOME/.bashrc"

if [ -f /usr/local/bin/ui.sh ]; then
    source /usr/local/bin/ui.sh
    clear_screen
    banner "STARDEW MOD VIBECODING" "Khong gian sang tao Mod Cinderbox Android"
    print_info "Go 'stardew-mod' de mo Menu dieu khien."
    print_line
fi
cd ~/stardew-workspace
EOF

chown -R "$INPUT_USER:$INPUT_USER" "$USER_HOME"

# Đánh dấu đã tạo user và lưu tên user mặc định
echo "$INPUT_USER" > /etc/stardew-default-user
touch /etc/stardew-user-created

echo
print_success "Da tao tai khoan '$INPUT_USER' va cap quyen sudo thanh cong."
print_box "Chuyen huong vao khong gian lam viec cua '$INPUT_USER'..."
echo
sleep 1
