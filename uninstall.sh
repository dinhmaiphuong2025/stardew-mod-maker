#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Kịch bản gỡ cài đặt sạch sẽ môi trường PRoot & Stardew VibeCoding
# Dùng để dọn dẹp hệ thống và kiểm thử lại kịch bản cài đặt
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$HOME/.stardew-proot-vibecoding"

# Tải thư viện UI style
if [ -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    source "$SCRIPT_DIR/scripts/ui.sh"
elif [ -f "$REPO_DIR/scripts/ui.sh" ]; then
    source "$REPO_DIR/scripts/ui.sh"
else
    RESET='\033[0m' BOLD='\033[1m' GRAY='\033[90m'
    RED='\033[1;31m' GREEN='\033[1;32m' YELLOW='\033[1;33m'
    BLUE='\033[1;34m' CYAN='\033[1;36m' WHITE='\033[1;37m'
    clear_screen() { printf "\033[2J\033[H"; }
    print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
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
    spin_task() {
        local label="$1"; shift
        printf "  %s... " "$label"
        if "$@" >/dev/null 2>&1; then
            printf "${GREEN}✓ Hoàn tất.${RESET}\n"
        else
            printf "${RED}✗ Thất bại.${RESET}\n"
        fi
    }
    print_step_bar() {
        printf "\n  [%d/%d] %s\n" "$1" "$2" "$3"
        print_line
    }
fi

clear_screen
banner "GỠ CÀI ĐẶT MÔI TRƯỜNG" "Dọn sạch PRoot Ubuntu & công cụ Stardew VibeCoding"

print_warning "Hành động này sẽ gỡ bỏ container Ubuntu, tài khoản và các lệnh tiện ích trên Termux."
print_info "Lưu ý: Thư mục game gốc và mod tại /sdcard/StardewValley sẽ ĐƯỢC GIỮ NGUYÊN AN TOÀN."
echo

if ! confirm "Bạn có chắc chắn muốn tiến hành dọn sạch để cài đặt lại từ đầu?"; then
    echo
    print_info "Đã hủy thao tác gỡ cài đặt."
    exit 0
fi

# Bước 1: Xóa các binary lệnh thực thi trên Termux
print_step_bar 1 4 "Gỡ bỏ các lệnh thực thi trên Termux"
rm -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" "$PREFIX/bin/stardew-code"
print_success "Đã gỡ bỏ lệnh 'ubuntu', 'Ubuntu' và 'stardew-code'."

# Bước 2: Gỡ bỏ container PRoot Ubuntu
print_step_bar 2 4 "Gỡ bỏ hệ điều hành PRoot Ubuntu"
if command -v proot-distro >/dev/null 2>&1 && proot-distro list | grep -q "ubuntu (installed)"; then
    spin_task "Đang gỡ bỏ container PRoot Ubuntu" proot-distro remove ubuntu
else
    print_info "PRoot Ubuntu chưa từng được cài đặt hoặc đã được gỡ trước đó."
fi

# Bước 3: Dọn dẹp file cấu hình override mount
print_step_bar 3 4 "Dọn dẹp cấu hình liên kết bộ nhớ"
if [ -f "$PREFIX/etc/proot-distro/ubuntu.override.conf" ]; then
    rm -f "$PREFIX/etc/proot-distro/ubuntu.override.conf"
    print_success "Đã xóa file cấu hình liên kết bộ nhớ ubuntu.override.conf."
else
    print_info "Không có cấu hình override nào cần xóa."
fi

# Bước 4: Xóa thư mục mã nguồn tạm
print_step_bar 4 4 "Dọn dẹp thư mục mã nguồn tạm"
rm -rf "$REPO_DIR"
print_success "Đã xóa thư mục mã nguồn tạm tại $REPO_DIR."

echo
print_line
print_box "Hệ thống đã được dọn sạch hoàn toàn! Sẵn sàng để kiểm thử lại."
echo
print_info "Lệnh cài đặt lại bằng 1 dòng:"
echo "  curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/install.sh | bash"
echo
