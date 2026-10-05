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
    print_warning() { printf "${YELLOW}⠶ %s${RESET}\n" "$1"; }
    print_info() { printf "${CYAN}⠿ %s${RESET}\n" "$1"; }
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
        local msg="$1" resp=""
        printf "%s (y/N): " "$msg"
        if [ -c /dev/tty ] && [ -r /dev/tty ]; then
            read -r resp < /dev/tty 2>/dev/null || read -r resp 2>/dev/null || resp="n"
        else
            read -r resp 2>/dev/null || resp="n"
        fi
        case "$resp" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
    }
    CURRENT_STEP=0
    TOTAL_STEPS=1
    init_progress() { TOTAL_STEPS="$1"; CURRENT_STEP=0; }
    step_task() {
        local label="$1"; shift
        CURRENT_STEP=$((CURRENT_STEP + 1))
        local pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
        printf "\r  [..] %3d%% %s\033[K" "$pct" "$label"
        if "$@" </dev/null >/dev/null 2>&1; then
            printf "\r  ${GREEN}✓${RESET}  %3d%% %s\033[K" "$pct" "$label"
        fi
    }
    finish_progress() { printf "\n"; }
fi

FORCE=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes|-f|--force) FORCE=1 ;;
    esac
done

clear_screen
banner "GỠ CÀI ĐẶT MÔI TRƯỜNG" "Dọn sạch PRoot Ubuntu & công cụ Stardew VibeCoding"

print_warning "Hành động này sẽ gỡ bỏ container Ubuntu, tài khoản và các lệnh tiện ích trên Termux."
print_info "Thư mục game gốc và mod tại /sdcard/StardewValley sẽ ĐƯỢC GIỮ NGUYÊN AN TOÀN."
echo

if [ "$FORCE" -eq 0 ]; then
    if ! confirm "Bạn có chắc chắn muốn tiến hành dọn sạch để cài đặt lại từ đầu?"; then
        echo
        print_info "Đã hủy thao tác gỡ cài đặt."
        exit 0
    fi
else
    print_info "Chế độ tự động (-y): Bỏ qua bước xác nhận."
fi

# Khởi tạo thanh tiến trình động duy nhất
init_progress 4
echo

# Bước 1: Xóa các binary lệnh thực thi trên Termux
step_task "Gỡ bỏ các lệnh thực thi trên Termux" rm -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" "$PREFIX/bin/stardew-code" "$PREFIX/etc/stardew-default-user"

# Bước 2: Gỡ bỏ container PRoot Ubuntu
remove_container() {
    if command -v proot-distro >/dev/null 2>&1; then
        proot-distro remove ubuntu 2>/dev/null || proot-distro reset ubuntu 2>/dev/null || true
    fi
}
step_task "Gỡ bỏ container PRoot Ubuntu" remove_container

# Bước 3: Dọn dẹp file cấu hình override mount
step_task "Dọn dẹp cấu hình liên kết bộ nhớ" rm -f "$PREFIX/etc/proot-distro/ubuntu.override.conf"

# Bước 4: Xóa thư mục mã nguồn tạm
step_task "Dọn dẹp thư mục mã nguồn tạm" rm -rf "$REPO_DIR"

finish_progress
echo
print_box "Hệ thống đã được dọn sạch hoàn toàn! Sẵn sàng kiểm thử lại."
echo
print_info "Lệnh cài đặt lại bằng 1 dòng:"
echo "  curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/install.sh | bash"
echo
