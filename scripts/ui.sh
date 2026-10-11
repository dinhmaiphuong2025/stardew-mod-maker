#!/usr/bin/env bash
# ==============================================================================
# UI Style Shell - Bộ hàm giao diện dòng lệnh (TUI)
# Phong cách OpenCode & DankMaterialShell - Ký tự Braille & Tiếng Việt đầy đủ dấu
# ==============================================================================

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

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

# Xóa màn hình chuẩn hệ thống (bao gồm xóa scrollback buffer tránh bị reflow khi zoom)
clear_screen() {
    if command -v clear >/dev/null 2>&1; then
        clear
    else
        printf "\033[H\033[2J\033[3J"
    fi
}

# Lấy độ rộng màn hình thực tế (tự co giãn khi người dùng zoom chữ trong Termux - thuần Bash không phụ thuộc awk)
get_term_cols() {
    local c="${COLUMNS:-}"
    if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
        local sz
        sz=$(stty size 2>/dev/null || true)
        c="${sz##* }"
    fi
    if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
        if command -v tput >/dev/null 2>&1; then
            c=$(tput cols 2>/dev/null || true)
        fi
    fi
    if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
        c=50
    fi
    echo "$c"
}

# Gạch ngang tự động căn chỉnh đúng độ rộng màn hình khi zoom (không bao giờ chạm mép gây lỗi wrap)
print_line() {
    local cols
    cols=$(get_term_cols)
    local width=$(( cols - 4 ))
    [ "$width" -gt 46 ] && width=46
    [ "$width" -lt 20 ] && width=20
    local line=""
    for ((l=0; l<width; l++)); do line="${line}─"; done
    printf "${GRAY}%s${RESET}\n" "$line"
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
    printf "  ${BOLD}${WHITE}%s${RESET}\n" "$title"
    if [ -n "$subtitle" ]; then
        printf "  ${GRAY}%s${RESET}\n" "$subtitle"
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

# Đo tốc độ mạng từ /proc/net/dev (thuần Bash không phụ thuộc công cụ ngoài)
get_net_rx_bytes() {
    local sum=0 iface rest rx
    if [ -r /proc/net/dev ]; then
        while IFS=":" read -r iface rest; do
            iface="${iface// /}"
            if [ "$iface" != "lo" ] && [ -n "$rest" ]; then
                set -- $rest
                rx="$1"
                if [ -n "$rx" ] && [ "$rx" -eq "$rx" ] 2>/dev/null; then
                    sum=$(( sum + rx ))
                fi
            fi
        done < /proc/net/dev
    fi
    echo "$sum"
}

format_speed() {
    local bps="$1"
    if [ "$bps" -ge 1048576 ]; then
        local mb=$(( bps / 1048576 ))
        local dec=$(( (bps % 1048576) * 10 / 1048576 ))
        printf "%d.%d MB/s" "$mb" "$dec"
    elif [ "$bps" -ge 1024 ]; then
        local kb=$(( bps / 1024 ))
        printf "%d KB/s" "$kb"
    elif [ "$bps" -gt 0 ]; then
        printf "%d B/s" "$bps"
    else
        printf "0 KB/s"
    fi
}

# Điểm nhấn thông báo không kẻ ô (thay thế khung chữ nhật tránh lỗi hiển thị trên mobile)
print_box() {
    local text="$1"
    printf "  ${CYAN}⠿${RESET} ${BOLD}%s${RESET}\n" "$text"
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

    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0
    local width=16
    local prev_rx
    prev_rx=$(get_net_rx_bytes 2>/dev/null || echo 0)
    local cur_speed=""

    # Tiến trình trước khi bắt đầu bước này (ví dụ bước 5/5 sẽ hiển thị 80% khi đang chạy, không hiển thị 100% quá sớm)
    local start_pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local start_filled=$(( CURRENT_STEP * width / TOTAL_STEPS ))
    local start_empty=$(( width - start_filled ))
    local run_bar=""
    for ((b=0; b<start_filled; b++)); do run_bar="${run_bar}█"; done
    for ((b=0; b<start_empty; b++)); do run_bar="${run_bar}░"; done

    printf "\033[?25l"
    "$@" </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        if [ $(( i % 10 )) -eq 0 ]; then
            local now_rx
            now_rx=$(get_net_rx_bytes 2>/dev/null || echo 0)
            if [ -n "$prev_rx" ] && [ "$now_rx" -ge "$prev_rx" ] 2>/dev/null; then
                local diff_rx=$(( now_rx - prev_rx ))
                local rate=$(( diff_rx * 5 / 4 ))
                if [ "$rate" -gt 1024 ]; then
                    cur_speed=$(format_speed "$rate")
                else
                    cur_speed=""
                fi
            fi
            prev_rx="$now_rx"
        fi

        local speed_str=""
        [ -n "$cur_speed" ] && speed_str=" ${GRAY}·${RESET} ${CYAN}${cur_speed}${RESET}"

        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}%b\033[K" \
            "${spin_chars[$idx]}" "$run_bar" "$start_pct" "$label" "$speed_str"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    printf "\033[?25h"

    CURRENT_STEP=$((CURRENT_STEP + 1))
    local end_pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
    local end_filled=$(( CURRENT_STEP * width / TOTAL_STEPS ))
    local end_empty=$(( width - end_filled ))
    local end_bar=""
    for ((b=0; b<end_filled; b++)); do end_bar="${end_bar}█"; done
    for ((b=0; b<end_empty; b++)); do end_bar="${end_bar}░"; done

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" \
            "$end_bar" "$end_pct" "$label"
        return 0
    else
        printf "\r  ${RED}✗${RESET} [${RED}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s thất bại (mã lỗi %d)${RESET}\033[K\n" \
            "$end_bar" "$end_pct" "$label" "$exit_code"
        return "$exit_code"
    fi
}

finish_progress() {
    printf "\n"
    print_line
}

# Spinner đơn cho các tác vụ như tải file hoặc xử lý
spin_task() {
    local label="$1"
    shift
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0
    local prev_rx
    prev_rx=$(get_net_rx_bytes 2>/dev/null || echo 0)
    local cur_speed=""

    printf "\033[?25l"
    "$@" </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        if [ $(( i % 10 )) -eq 0 ]; then
            local now_rx
            now_rx=$(get_net_rx_bytes 2>/dev/null || echo 0)
            if [ -n "$prev_rx" ] && [ "$now_rx" -ge "$prev_rx" ] 2>/dev/null; then
                local diff_rx=$(( now_rx - prev_rx ))
                local rate=$(( diff_rx * 5 / 4 ))
                if [ "$rate" -gt 1024 ]; then
                    cur_speed=$(format_speed "$rate")
                else
                    cur_speed=""
                fi
            fi
            prev_rx="$now_rx"
        fi

        local speed_str=""
        [ -n "$cur_speed" ] && speed_str=" ${GRAY}·${RESET} ${CYAN}${cur_speed}${RESET}"

        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET}  ${WHITE}%s...${RESET}%b\033[K" "${spin_chars[$idx]}" "$label" "$speed_str"
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
        ( read -r _ < /dev/tty ) 2>/dev/null || read -r _ 2>/dev/null || true
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
        choice=$( ( read -r val < /dev/tty && echo "$val" ) 2>/dev/null ) || choice=""
        [ -z "$choice" ] && read -r choice 2>/dev/null || true
    else
        read -r choice 2>/dev/null || choice="0"
    fi
    choice=$(echo "$choice" | tr -d '[:space:]')
    echo "$choice"
}

# Xác nhận Có / Không (Mặc định Không: y/N)
confirm() {
    local msg="$1"
    local resp=""
    printf "%s (y/N): " "$msg" >&2
    if [ -t 0 ]; then
        read -r resp || resp="n"
    elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
        resp=$( ( read -r val < /dev/tty && echo "$val" ) 2>/dev/null ) || resp=""
        [ -z "$resp" ] && read -r resp 2>/dev/null || true
    else
        read -r resp 2>/dev/null || resp="n"
    fi
    case "$resp" in
        [yY]|[yY][eE][sS]) return 0 ;;
        *) return 1 ;;
    esac
}

# Xác nhận Có / Không (Mặc định Có: Y/n - Tiện lợi khi chỉ nhấn Enter)
confirm_default_yes() {
    local msg="$1"
    local resp=""
    printf "%s (Y/n): " "$msg" >&2
    if [ -t 0 ]; then
        read -r resp || resp="y"
    elif [ -c /dev/tty ] && [ -r /dev/tty ]; then
        resp=$( ( read -r val < /dev/tty && echo "$val" ) 2>/dev/null ) || resp=""
    else
        read -r resp 2>/dev/null || resp="y"
    fi
    [ -z "$resp" ] && resp="y"
    case "$resp" in
        [nN]|[nN][oO]) return 1 ;;
        *) return 0 ;;
    esac
}
