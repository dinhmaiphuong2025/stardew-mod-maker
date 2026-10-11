#!/usr/bin/env bash
# ==============================================================================
# Script test local: Trình diễn hoạt ảnh giao diện TUI thuần túy
# KHÔNG tải về, KHÔNG cài đặt, KHÔNG ảnh hưởng hệ thống
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    source "$SCRIPT_DIR/scripts/ui.sh"
fi

clear_screen
banner "STARDEW MOD VIBECODING" "Bản thử nghiệm giao diện TUI thuần túy (Test Local)"

echo
print_info "Đang chạy mô phỏng hoạt ảnh thanh tiến trình 2 dòng..."
echo

# Các bước mô phỏng thực tế với tốc độ mạng minh họa
steps=(
    "10:Kiểm tra bộ nhớ thiết bị & Termux:"
    "25:Cập nhật kho gói Termux:1.2 MB/s"
    "45:Tải hệ điều hành PRoot Ubuntu:3.8 MB/s"
    "60:Thiết lập container PRoot Ubuntu:"
    "78:Tải & cài đặt .NET 10.0 SDK:5.2 MB/s"
    "92:Cấu hình stardew-mod CLI & công cụ:"
    "100:Hoàn tất cài đặt môi trường:"
)

spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
n_chars=${#spin_chars[@]}
i=0
cur_pct=0

cols=$(get_term_cols)
bar_w=$(( cols - 16 ))
[ "$bar_w" -lt 16 ] && bar_w=16
[ "$bar_w" -gt 42 ] && bar_w=42

printf "\033[?25l"

for step in "${steps[@]}"; do
    target_pct="${step%%:*}"
    rest="${step#*:}"
    label="${rest%%:*}"
    speed="${rest#*:}"

    speed_str=""
    [ -n "$speed" ] && speed_str=" ${GRAY}·${RESET} ${CYAN}${speed}${RESET}"

    max_label_w=$(( cols - 6 ))
    [ "$max_label_w" -lt 20 ] && max_label_w=20
    display_label="${label:0:$max_label_w}"

    while [ "$cur_pct" -lt "$target_pct" ]; do
        cur_pct=$(( cur_pct + 1 ))
        filled=$(( cur_pct * bar_w / 100 ))
        empty=$(( bar_w - filled ))
        bar=""
        for ((b=0; b<filled; b++)); do bar="${bar}▆"; done
        for ((b=0; b<empty; b++)); do bar="${bar}░"; done

        idx=$(( i % n_chars ))
        # Xuất 2 dòng: Dòng 1 = Thanh tiến trình dài (giảm 20% độ dày) | Dòng 2 = Nhãn text đầy đủ + Tốc độ mạng
        printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}\033[K\n    ${WHITE}%s${RESET}%b\033[K\033[1A\r" \
            "${spin_chars[$idx]}" "$bar" "$cur_pct" "$display_label" "$speed_str"
        i=$(( i + 1 ))
        sleep 0.05
    done
    sleep 0.25
done

full_bar=""
for ((b=0; b<bar_w; b++)); do full_bar="${full_bar}▆"; done
printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}100%%${RESET}\033[K\n    ${WHITE}Cài đặt hoàn tất${RESET}\033[K\n" "$full_bar"
printf "\033[?25h"

echo
print_line
echo

# Mô phỏng thông báo tài khoản & workspace không kẻ khung chữ nhật
print_success "Đã tạo tài khoản 'stardew' và cấp quyền sudo thành công!"
echo -e "  ${CYAN}•${RESET} Không gian làm việc: ${BOLD}${WHITE}/home/stardew/stardew-workspace${RESET}"
echo -e "  ${CYAN}•${RESET} Thư mục game /sdcard: ${GRAY}/sdcard/StardewValley${RESET}"
echo
print_success "Cài đặt thành công! Môi trường VibeCoding đã sẵn sàng."
echo -e "  ${CYAN}•${RESET} Khởi động Ubuntu: ${BOLD}${YELLOW}ubuntu${RESET}"
echo
