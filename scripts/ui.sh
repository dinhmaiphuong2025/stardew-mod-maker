#!/usr/bin/env bash
# ==============================================================================
# UI Style Shell - Bộ hàm giao diện dòng lệnh (TUI)
# Phong cách OpenCode & DankMaterialShell - Tiếng Việt đầy đủ dấu
# ==============================================================================

# Màu sắc
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
MAGENTA='\033[1;35m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[90m'

# Xóa màn hình
clear_screen() {
    printf "\033[2J\033[H"
}

# Gạch ngang màu xám dài 61 ký tự
print_line() {
    printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"
}

# Dấu nhắc lệnh
print_prompt() {
    printf "${GREEN}❯ ${RESET}"
}

# Thông báo trạng thái (Tiếng Việt chuẩn)
print_success() {
    printf "${GREEN}✓ %s${RESET}\n" "$1"
}

print_error() {
    printf "${RED}✗ %s${RESET}\n" "$1"
}

print_warning() {
    printf "${YELLOW}⚠ %s${RESET}\n" "$1"
}

print_info() {
    printf "${BLUE}ℹ %s${RESET}\n" "$1"
}

# Banner và Header
banner() {
    local title="$1"
    local subtitle="$2"
    printf "      ${BOLD}${WHITE}%s${RESET}\n" "$title"
    if [ -n "$subtitle" ]; then
        printf "      ${GRAY}%s${RESET}\n" "$subtitle"
    fi
    print_line
}

print_header() {
    local title="$1"
    printf "${BOLD}== %s ==${RESET}\n" "$title"
    print_line
}

# Menu lựa chọn
print_menu() {
    local items=("$@")
    local idx=1
    for item in "${items[@]}"; do
        printf "  ${CYAN}[%d]${RESET} %s\n" "$idx" "$item"
        idx=$((idx + 1))
    done
    printf "  ${GRAY}[0]${RESET} Thoát\n"
    print_line
}

# Khung bo góc quanh text
print_box() {
    local text="$1"
    local len=${#text}
    local border=""
    for ((i=0; i<len+2; i++)); do
        border="${border}─"
    done
    printf "  ${GRAY}┌%s┐${RESET}\n" "$border"
    printf "  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n" "$text"
    printf "  ${GRAY}└%s┘${RESET}\n" "$border"
}

# Thanh tiến trình bước (Step Progress Bar phong cách DankMaterialShell / OpenCode)
print_step_bar() {
    local current="$1"
    local total="$2"
    local title="$3"
    local width=16

    local percent=$(( current * 100 / total ))
    local filled=$(( current * width / total ))
    local empty=$(( width - filled ))

    local bar=""
    for ((i=0; i<filled; i++)); do bar="${bar}█"; done
    for ((i=0; i<empty; i++)); do bar="${bar}░"; done

    printf "\n  ${GRAY}[%d/%d]${RESET} ${CYAN}[%s]${RESET} ${BOLD}%3d%%${RESET}  %s\n" \
        "$current" "$total" "$bar" "$percent" "$title"
    print_line
}

# Spinner động chạy ngầm tác vụ thực tế (Active Task Spinner)
spin_task() {
    local label="$1"
    shift
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0

    # Ẩn con trỏ terminal
    printf "\033[?25l"

    # Chạy tác vụ ngầm
    "$@" >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET} %s..." "${spin_chars[$idx]}" "$label"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?

    # Hiện lại con trỏ terminal và xóa dòng hiện tại
    printf "\033[?25h"
    printf "\r\033[K"

    if [ "$exit_code" -eq 0 ]; then
        print_success "$label hoàn tất."
    else
        print_error "$label thất bại (mã lỗi: $exit_code)."
        return "$exit_code"
    fi
}

# Chờ phím Enter
wait_for_enter() {
    printf "${GRAY}Nhấn phím Enter để tiếp tục...${RESET}"
    read -r
}

# Đọc lựa chọn của người dùng
get_choice() {
    local choice
    print_prompt
    read -r choice
    echo "$choice"
}

# Xác nhận Có / Không
confirm() {
    local msg="$1"
    local resp
    printf "%s (y/N): " "$msg"
    read -r resp
    case "$resp" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}
