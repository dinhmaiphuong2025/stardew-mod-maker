#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Kịch bản gỡ cài đặt sạch sẽ môi trường PRoot & Stardew VibeCoding
# Tự chứa hoàn toàn (Self-contained) - 1 thanh tiến trình động duy nhất
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

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
print_prompt() { printf "${GREEN}❯ ${RESET}" >&2; }
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

# Khung bo góc quanh text (chuẩn hóa độ dài UTF-8 không bị lệch viền)
print_box() {
    local text="$1"
    local len
    len=$(LC_ALL=C.UTF-8 printf "%s" "$text" | wc -m 2>/dev/null || echo "${#text}")
    len=$(echo "$len" | tr -d '[:space:]')
    local border=""
    for ((i=0; i<len+2; i++)); do
        border="${border}─"
    done
    printf "  ${GRAY}┌%s┐${RESET}\n" "$border"
    printf "  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n" "$text"
    printf "  ${GRAY}└%s┘${RESET}\n" "$border"
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
# THANH TIẾN TRÌNH ĐỘNG DUY NHẤT (Single Unified Progress Bar)
# ------------------------------------------------------------------------------
run_single_progress() {
    local label="$1"
    shift
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local width=16
    local i=0
    local pct=10

    printf "\033[?25l"
    "$@" </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local idx=$(( i % n_chars ))
        if [ "$pct" -lt 90 ] && [ $(( i % 4 )) -eq 0 ]; then
            pct=$(( pct + 5 ))
        fi
        local filled=$(( pct * width / 100 ))
        local empty=$(( width - filled ))
        local bar=""
        for ((b=0; b<filled; b++)); do bar="${bar}█"; done
        for ((b=0; b<empty; b++)); do bar="${bar}░"; done

        printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" \
            "${spin_chars[$idx]}" "$bar" "$pct" "$label"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    printf "\033[?25h"

    local full_bar=""
    for ((b=0; b<width; b++)); do full_bar="${full_bar}█"; done

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}100%%${RESET}  ${WHITE}Gỡ bỏ môi trường hoàn tất${RESET}\033[K\n" "$full_bar"
        return 0
    else
        printf "\r  ${RED}✗${RESET} Gỡ bỏ thất bại (mã lỗi %d)\033[K\n" "$exit_code"
        return "$exit_code"
    fi
}

FORCE=0
for arg in "$@"; do
    case "$arg" in
        -y|--yes|-f|--force) FORCE=1 ;;
    esac
done

REPO_DIR="$HOME/.stardew-mod-maker"

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

echo

# Hàm thực thi dọn dẹp toàn bộ hệ thống
do_uninstall() {
    # 1. Gỡ bỏ các binary lệnh thực thi trên Termux
    rm -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" "$PREFIX/bin/stardew-code" "$PREFIX/etc/stardew-default-user" 2>/dev/null || true

    # 2. Gỡ bỏ container PRoot Ubuntu
    if command -v proot-distro >/dev/null 2>&1; then
        proot-distro remove ubuntu >/dev/null 2>&1 || true
        proot-distro reset ubuntu >/dev/null 2>&1 || true
    fi
    rm -rf "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" \
           "$PREFIX/var/lib/proot-distro/containers/ubuntu" \
           "$HOME/.local/share/proot-distro/containers/ubuntu" 2>/dev/null || true

    # 3. Dọn dẹp cấu hình liên kết bộ nhớ
    rm -f "$PREFIX/etc/proot-distro/ubuntu.override.conf" 2>/dev/null || true

    # 4. Xóa thư mục mã nguồn tạm
    rm -rf "$REPO_DIR" 2>/dev/null || true
}

# Chạy đúng 1 thanh tiến trình duy nhất
run_single_progress "Đang dọn dẹp và gỡ bỏ toàn bộ môi trường..." do_uninstall

print_line
echo
print_box "Đã dọn sạch hệ thống! Sẵn sàng cài đặt lại."
echo
print_info "Lệnh cài đặt lại bằng 1 dòng:"
echo "  curl -sSL https://raw.githubusercontent.com/dinhmaiphuong2025/stardew-mod-maker/main/install.sh | bash"
echo
