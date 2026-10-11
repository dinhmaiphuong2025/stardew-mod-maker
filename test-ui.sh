#!/usr/bin/env bash
# ==============================================================================
# Script test local: Giao diện tiến trình & tốc độ mạng cố định trên cùng
# ĐẦY ĐỦ 8 BƯỚC CÀI ĐẶT THỰC TẾ + FORM KHỞI TẠO TÀI KHOẢN TỐI ƯU
# KHÔNG tải về, KHÔNG cài đặt, KHÔNG ảnh hưởng hệ thống
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    source "$SCRIPT_DIR/scripts/ui.sh"
fi

RESET='\033[0m'
BOLD='\033[1m'
GRAY='\033[90m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
YELLOW='\033[1;33m'

cols=$(get_term_cols)
# Thanh tiến trình vừa vặn với độ rộng màn hình Termux, chừa cột tốc độ mạng bên phải
bar_w=$(( cols - 28 ))
[ "$bar_w" -lt 16 ] && bar_w=16
[ "$bar_w" -gt 38 ] && bar_w=38

spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
n_chars=${#spin_chars[@]}

# ĐẦY ĐỦ 8 BƯỚC CÀI ĐẶT CHI TIẾT THEO THỰC TẾ HỆ THỐNG
steps=(
    "10:Kiểm tra quyền truy cập bộ nhớ thiết bị Android (/sdcard):"
    "22:Cập nhật danh sách kho gói Termux (apt update):1.2 MB/s"
    "35:Cài đặt gói công cụ lõi Termux (proot-distro, git, curl, jq):2.4 MB/s"
    "50:Tải hệ điều hành PRoot Ubuntu 24.04 (rootfs aarch64):4.8 MB/s"
    "65:Thiết lập container Ubuntu & liên kết thư mục /sdcard:"
    "78:Cập nhật kho gói Ubuntu & cài đặt thư viện phụ thuộc:3.6 MB/s"
    "90:Tải và cài đặt .NET 10.0 SDK & thư viện SMAPI:5.8 MB/s"
    "100:Khởi tạo stardew-mod CLI, template dự án & môi trường VibeCoding:"
)

clear_screen
printf "\033[?25l"

history=()
cur_pct=0
i=0

draw_all() {
    local active_step="$1"
    local active_speed="$2"
    local is_done="$3"

    local filled=$(( cur_pct * bar_w / 100 ))
    local empty=$(( bar_w - filled ))
    local bar_f=""
    local bar_e=""
    for ((b=0; b<filled; b++)); do bar_f="${bar_f}▆"; done
    for ((b=0; b<empty; b++)); do bar_e="${bar_e} "; done

    local sp_str="         "
    [ -n "$active_speed" ] && sp_str=$(printf "%9s" "$active_speed")

    local idx=$(( i % n_chars ))
    local spin_icon="${spin_chars[$idx]}"
    [ "$is_done" = "1" ] && spin_icon="✓"

    local pct_str
    pct_str=$(printf "%3d%%" "$cur_pct")

    local buf="\033[H"
    buf+="  ${BOLD}${WHITE}STARDEW MOD VIBECODING${RESET}\033[K\n"
    buf+="  ${GRAY}"
    for ((l=0; l<cols-4 && l<46; l++)); do buf+="─"; done
    buf+="${RESET}\033[K\n"

    # DÒNG CỐ ĐỊNH DUY NHẤT TRÊN CÙNG: THANH TIẾN TRÌNH + % + TỐC ĐỘ MẠNG
    if [ "$is_done" = "1" ]; then
        buf+="  ${GREEN}✓${RESET} [${GREEN}${bar_f}${RESET}${bar_e}] ${BOLD}100%${RESET}           \033[K\n"
    else
        buf+="  ${CYAN}${spin_icon}${RESET} [${GREEN}${bar_f}${RESET}${bar_e}] ${BOLD}${pct_str}${RESET}  ${CYAN}${sp_str}${RESET}\033[K\n"
    fi
    buf+="\n"

    # DANH SÁCH LƯU VẾT TỪNG TIẾN TRÌNH Ở BÊN DƯỚI
    for h in "${history[@]}"; do
        buf+="  ${GREEN}✓${RESET} ${WHITE}${h}${RESET}\033[K\n"
    done

    # Tiến trình hiện tại đang xử lý (nếu chưa xong)
    if [ "$is_done" != "1" ] && [ -n "$active_step" ]; then
        buf+="  ${CYAN}❯${RESET} ${WHITE}${active_step}...${RESET}\033[K\n"
    fi

    printf "%b" "$buf"
}

for step in "${steps[@]}"; do
    target_pct="${step%%:*}"
    rest="${step#*:}"
    label="${rest%%:*}"
    speed="${rest#*:}"

    while [ "$cur_pct" -lt "$target_pct" ]; do
        cur_pct=$(( cur_pct + 1 ))
        i=$(( i + 1 ))
        draw_all "$label" "$speed" "0"
        sleep 0.03
    done

    # Đưa bước vừa xong vào lịch sử (sẽ thành dấu tích xanh cố định)
    history+=("$label")
    draw_all "$label" "$speed" "0"
    sleep 0.15
done

# Hoàn tất 100%
cur_pct=100
draw_all "" "" "1"
printf "\033[?25h"

echo
print_line
echo

# ==============================================================================
# FORM THIẾT LẬP TÀI KHOẢN TỐI ƯU GỌN GÀNG (DEMO INTERACTIVE)
# ==============================================================================
banner "KHỞI TẠO TÀI KHOẢN" "Thiết lập quyền sudo cho không gian làm việc Ubuntu"

# 1. Nhập tên tài khoản (gợi ý mặc định 'stardew' ngay trong ngoặc)
printf "  ${CYAN}❯${RESET} Tên người dùng [mặc định: ${YELLOW}stardew${RESET}]: "
INPUT_USER=""
read -r INPUT_USER 2>/dev/null || INPUT_USER="stardew"
INPUT_USER=$(echo "$INPUT_USER" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')
[ -z "$INPUT_USER" ] && INPUT_USER="stardew"

# 2. Nhập mật khẩu (gọn gàng, nhấn Enter là bỏ qua)
printf "  ${CYAN}❯${RESET} Mật khẩu sudo [nhấn Enter để bỏ qua]: "
INPUT_PASS=""
read -rs INPUT_PASS 2>/dev/null || INPUT_PASS=""
echo

# 3. Tắt hỏi mật khẩu sudo (mặc định Y, chỉ cần gõ Enter)
NOPASSWD="Có"
printf "  ${CYAN}❯${RESET} Miễn hỏi mật khẩu khi sudo? (Y/n) [${GREEN}Y${RESET}]: "
CONFIRM_SUDO=""
read -r CONFIRM_SUDO 2>/dev/null || CONFIRM_SUDO="y"
[ -z "$CONFIRM_SUDO" ] && CONFIRM_SUDO="y"
case "$CONFIRM_SUDO" in
    [nN]|[nN][oO]) NOPASSWD="Không" ;;
    *) NOPASSWD="Có" ;;
esac

echo
print_success "Đã tạo tài khoản '$INPUT_USER' và cấp quyền sudo thành công!"
echo -e "  ${CYAN}•${RESET} Không gian làm việc:  ${BOLD}${WHITE}/home/$INPUT_USER/stardew-workspace${RESET}"
echo -e "  ${CYAN}•${RESET} Miễn mật khẩu sudo:    ${YELLOW}$NOPASSWD${RESET}"
echo -e "  ${CYAN}•${RESET} Thư mục game /sdcard: ${GRAY}/sdcard/StardewValley${RESET}"
echo
print_success "Cài đặt thành công! Môi trường VibeCoding đã sẵn sàng."
printf "  ${CYAN}•${RESET} Khởi động Ubuntu:      ${BOLD}${YELLOW}ubuntu${RESET}\n\n"
