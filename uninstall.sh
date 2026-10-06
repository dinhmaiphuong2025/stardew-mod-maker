#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Kịch bản gỡ cài đặt sạch sẽ môi trường PRoot & Stardew VibeCoding
# Tự chứa hoàn toàn (Self-contained) - 1 thanh tiến trình động duy nhất
# ==============================================================================

set -e

RESET='\033[0m'
BOLD='\033[1m'
GRAY='\033[90m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'

clear_screen() { printf "\033[2J\033[H"; }
print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
print_prompt() { printf "${GREEN}❯ ${RESET}"; }
print_success() { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
print_error() { printf "${RED}✗ %s${RESET}\n" "$1"; }
print_warning() { printf "${YELLOW}⠶ %s${RESET}\n" "$1"; }
print_info() { printf "${CYAN}⠿ %s${RESET}\n" "$1"; }

banner() {
    local title="$1" subtitle="$2"
    printf "      ${BOLD}${WHITE}%s${RESET}\n" "$title"
    [ -n "$subtitle" ] && printf "      ${GRAY}%s${RESET}\n" "$subtitle"
    print_line
}

print_box() {
    local text="$1" len=${#text} border=""
    for ((i=0; i<len+2; i++)); do border="${border}─"; done
    printf "  ${GRAY}┌%s┐${RESET}\n  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n  ${GRAY}└%s┘${RESET}\n" "$border" "$text" "$border"
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

# ------------------------------------------------------------------------------
# THANH TIẾN TRÌNH ĐỘNG DUY NHẤT (Single Animated Progress Bar)
# ------------------------------------------------------------------------------
CURRENT_STEP=0
TOTAL_STEPS=1

init_progress() {
    TOTAL_STEPS="$1"
    CURRENT_STEP=0
}

step_task() {
    local label="$1"
    shift
    CURRENT_STEP=$((CURRENT_STEP + 1))

    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0
    local width=16

    local percent=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local filled=$(( CURRENT_STEP * width / TOTAL_STEPS ))
    local empty=$(( width - filled ))
    local bar=""
    for ((b=0; b<filled; b++)); do bar="${bar}█"; done
    for ((b=0; b<empty; b++)); do bar="${bar}░"; done

    printf "\033[?25l"
    "$@" </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" \
            "${spin_chars[$idx]}" "$bar" "$percent" "$label"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    printf "\033[?25h"

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K\n" \
            "$bar" "$percent" "$label"
        return 0
    else
        printf "\r  ${RED}✗${RESET} [${RED}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s thất bại (lỗi %d)${RESET}\033[K\n" \
            "$bar" "$percent" "$label" "$exit_code"
        return "$exit_code"
    fi
}

finish_progress() {
    print_line
}

FORCE=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes|-f|--force) FORCE=1 ;;
    esac
done

REPO_DIR="$HOME/.stardew-proot-vibecoding"

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
clean_bins() {
    rm -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" "$PREFIX/bin/stardew-code" "$PREFIX/etc/stardew-default-user"
}
step_task "Gỡ bỏ các lệnh thực thi trên Termux" clean_bins

# Bước 2: Gỡ bỏ container PRoot Ubuntu
clean_container() {
    if command -v proot-distro >/dev/null 2>&1; then
        proot-distro remove ubuntu >/dev/null 2>&1 || true
        proot-distro reset ubuntu >/dev/null 2>&1 || true
    fi
    rm -rf "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" \
           "$PREFIX/var/lib/proot-distro/containers/ubuntu" \
           "$HOME/.local/share/proot-distro/containers/ubuntu" 2>/dev/null || true
}
step_task "Gỡ bỏ container PRoot Ubuntu" clean_container

# Bước 3: Dọn dẹp cấu hình liên kết bộ nhớ
clean_conf() {
    rm -f "$PREFIX/etc/proot-distro/ubuntu.override.conf"
}
step_task "Dọn dẹp cấu hình liên kết bộ nhớ" clean_conf

# Bước 4: Xóa thư mục mã nguồn tạm
clean_repo() {
    rm -rf "$REPO_DIR"
}
step_task "Dọn dẹp thư mục mã nguồn tạm" clean_repo

finish_progress
echo
print_box "Hệ thống đã được dọn sạch hoàn toàn! Sẵn sàng kiểm thử lại."
echo
print_info "Lệnh cài đặt lại bằng 1 dòng:"
echo "  curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-proot-vibecoding/main/install.sh | bash"
echo
