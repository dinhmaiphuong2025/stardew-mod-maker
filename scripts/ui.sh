#!/usr/bin/env bash
# ==============================================================================
# UI Style Shell - Bộ hàm giao diện dòng lệnh (TUI)
# Phong cách OpenCode & DankMaterialShell - Ký tự Braille & Tiếng Việt đầy đủ dấu
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

# Dấu nhắc lệnh (in ra stderr để không làm bẩn giá trị trả về của hàm)
print_prompt() {
    printf "${GREEN}❯ ${RESET}" >&2
}

# Thông báo trạng thái (chuẩn TUI Braille, không dùng ! hoặc emoji)
print_success() {
    printf "${GREEN}✓ %s${RESET}\n" "$1"
}

print_error() {
    printf "${RED}✗ %s${RESET}\n" "$1"
}

print_warning() {
    printf "${YELLOW}⠶ %s${RESET}\n" "$1"
}

print_info() {
    printf "${CYAN}⠿ %s${RESET}\n" "$1"
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
        printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" \
            "$bar" "$percent" "$label"
        return 0
    else
        printf "\r  ${RED}✗${RESET} [${RED}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s thất bại (mã lỗi %d)${RESET}\033[K\n" \
            "$bar" "$percent" "$label" "$exit_code"
        return "$exit_code"
    fi
}

finish_progress() {
    printf "\n"
    print_line
}

# Spinner đơn cho các tác vụ như biên dịch mod
spin_task() {
    local label="$1"
    shift
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0

    printf "\033[?25l"
    "$@" </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET}  ${WHITE}%s...${RESET}\033[K" "${spin_chars[$idx]}" "$label"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    printf "\033[?25h"

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${RESET}  ${WHITE}%s hoàn tất.${RESET}\033[K\n" "$label"
        return 0
    else
        printf "\r  ${RED}✗${RESET}  ${WHITE}%s thất bại (mã lỗi %d).${RESET}\033[K\n" "$label" "$exit_code"
        return "$exit_code"
    fi
}

# Chờ phím Enter
wait_for_enter() {
    printf "${GRAY}Nhấn phím Enter để tiếp tục...${RESET}" >&2
    if [ -t 0 ]; then
        read -r _ || true
    elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
        read -r _ < /dev/tty 2>/dev/null || read -r _ 2>/dev/null || true
    else
        read -r _ 2>/dev/null || true
    fi
}

# Đọc lựa chọn của người dùng (trả về giá trị sạch trên stdout)
get_choice() {
    local choice=""
    print_prompt
    if [ -t 0 ]; then
        read -r choice || choice="0"
    elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
        read -r choice < /dev/tty 2>/dev/null || choice="0"
    else
        read -r choice 2>/dev/null || choice="0"
    fi
    choice=$(echo "$choice" | tr -d '[:space:]')
    echo "$choice"
}

# Xác nhận Có / Không
confirm() {
    local msg="$1"
    local resp=""
    printf "%s (y/N): " "$msg" >&2
    if [ -t 0 ]; then
        read -r resp || resp="n"
    elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
        read -r resp < /dev/tty 2>/dev/null || read -r resp 2>/dev/null || resp="n"
    else
        read -r resp 2>/dev/null || resp="n"
    fi
    case "$resp" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}
