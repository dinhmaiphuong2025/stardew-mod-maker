#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Tuân thủ UI Style Shell (ui-style-shell) - Ký tự Braille & Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export PROOT_NO_SECCOMP=1
export DEBIAN_FRONTEND=noninteractive

# Khóa cứng cấu hình dpkg & apt để không bao giờ dừng hỏi ghi đè (openssl.cnf, etc.)
if [ -n "$PREFIX" ] && [ -d "$PREFIX" ]; then
    mkdir -p "$PREFIX/etc/dpkg/dpkg.cfg.d" "$PREFIX/etc/apt/apt.conf.d" 2>/dev/null || true
    printf "force-confdef\nforce-confold\n" > "$PREFIX/etc/dpkg/dpkg.cfg.d/99force-conf" 2>/dev/null || true
    printf 'Dpkg::Options { "--force-confdef"; "--force-confold"; };\n' > "$PREFIX/etc/apt/apt.conf.d/99force-conf" 2>/dev/null || true
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$HOME/.stardew-mod-maker"

# Tự động nạp mã nguồn khi chạy trực tiếp qua: curl ... | bash
if [ ! -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    printf "Đang chuẩn bị gói cài đặt từ GitHub...\n"
    apt-get update -y >/dev/null 2>&1 || true
    apt-get install -y --no-install-recommends openssl curl git jq tar >/dev/null 2>&1 || true
    rm -rf "$REPO_DIR"
    git clone --depth 1 https://github.com/dinhmaiphuong2025/stardew-mod-maker.git "$REPO_DIR" >/dev/null 2>&1

    if [ -c /dev/tty ] && [ -r /dev/tty ]; then
        exec bash "$REPO_DIR/install.sh" "$@" < /dev/tty
    else
        exec bash "$REPO_DIR/install.sh" "$@"
    fi
fi

# Tải thư viện UI style hoặc dùng hàm tích hợp sẵn
if [ -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    source "$SCRIPT_DIR/scripts/ui.sh"
elif [ -f "$REPO_DIR/scripts/ui.sh" ]; then
    source "$REPO_DIR/scripts/ui.sh"
else
    RESET='\033[0m' BOLD='\033[1m' GRAY='\033[90m'
    RED='\033[1;31m' GREEN='\033[1;32m' YELLOW='\033[1;33m'
    CYAN='\033[1;36m' WHITE='\033[1;37m'
    clear_screen() { printf "\033[2J\033[H"; }
    get_term_cols() {
        local c="${COLUMNS:-}"
        if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
            local sz
            sz=$(stty size 2>/dev/null || true)
            c="${sz##* }"
        fi
        if [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null; then
            command -v tput >/dev/null 2>&1 && c=$(tput cols 2>/dev/null || true)
        fi
        [ -z "$c" ] || [ "$c" -le 0 ] 2>/dev/null && c=50
        echo "$c"
    }
    print_line() {
        local cols
        cols=$(get_term_cols)
        local width=$(( cols - 2 ))
        [ "$width" -gt 60 ] && width=60
        [ "$width" -lt 25 ] && width=25
        local line=""
        for ((l=0; l<width; l++)); do line="${line}─"; done
        printf "${GRAY}%s${RESET}\n" "$line"
    }
    print_prompt() { printf "${GREEN}❯ ${RESET}" >&2; }
    print_success() { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
    print_error() { printf "${RED}✗ %s${RESET}\n" "$1"; }
    print_warning() { printf "${YELLOW}⠶ %s${RESET}\n" "$1"; }
    print_info() { printf "${CYAN}⠿ %s${RESET}\n" "$1"; }
    banner() {
        printf "  ${BOLD}${WHITE}%s${RESET}\n" "$1"
        [ -n "$2" ] && printf "  ${GRAY}%s${RESET}\n" "$2"
        print_line
    }
    print_box() {
        local text="$1"
        local len
        len=$(LC_ALL=C.UTF-8 printf "%s" "$text" | wc -m 2>/dev/null || echo "${#text}")
        len=$(echo "$len" | tr -d '[:space:]')
        local border=""
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
    CURRENT_STEP=0; TOTAL_STEPS=1
    init_progress() { TOTAL_STEPS="$1"; CURRENT_STEP=0; }
    step_task() {
        local label="$1"; shift
        local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
        local n_chars=${#spin_chars[@]} i=0 width=16
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
            local idx=$(( i % n_chars ))
            printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" "${spin_chars[$idx]}" "$run_bar" "$start_pct" "$label"
            i=$(( i + 1 )); sleep 0.08
        done
        wait "$pid"; local exit_code=$?
        printf "\033[?25h"

        CURRENT_STEP=$((CURRENT_STEP + 1))
        local end_pct=$(( CURRENT_STEP * 100 / TOTAL_STEPS ))
        local end_filled=$(( CURRENT_STEP * width / TOTAL_STEPS ))
        local end_empty=$(( width - end_filled ))
        local end_bar=""
        for ((b=0; b<end_filled; b++)); do end_bar="${end_bar}█"; done
        for ((b=0; b<end_empty; b++)); do end_bar="${end_bar}░"; done

        if [ "$exit_code" -eq 0 ]; then
            printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K" "$end_bar" "$end_pct" "$label"
            return 0
        else
            printf "\r  ${RED}✗${RESET} [${RED}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%s${RESET}\033[K\n" "$end_bar" "$end_pct" "$label"
            return 0
        fi
    }
    finish_progress() { printf "\n"; print_line; }
fi

# Hàm kiểm tra container ubuntu thực sự khả dụng (có shell /bin/sh hợp lệ)
is_ubuntu_installed() {
    if proot-distro login ubuntu -- /bin/sh -c "exit 0" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

clear_screen
banner "STARDEW MOD VIBECODING" "Cài đặt tự động môi trường Termux & PRoot Ubuntu"

# 1. Kiểm tra môi trường Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    print_error "Kịch bản này bắt buộc phải chạy trong ứng dụng Termux trên Android."
    exit 1
fi

TMP_DIR="${TMPDIR:-$PREFIX/tmp}"
mkdir -p "$TMP_DIR"
STATUS_FILE="$TMP_DIR/.stardew_install_status"
INSTALL_LOG="$TMP_DIR/stardew_install.log"
rm -f "$STATUS_FILE" "$INSTALL_LOG"

# Toàn bộ quy trình cài đặt thực hiện ngầm trong 1 luồng
do_install() {
    set +e
    # 1. Kiểm tra quyền bộ nhớ
    echo "10:Kiểm tra bộ nhớ thiết bị" > "$STATUS_FILE"
    if [ ! -d "$HOME/storage/shared" ]; then
        termux-setup-storage >/dev/null 2>&1 || true
        sleep 1
    fi

    # 2. Cài đặt các gói công cụ Termux
    echo "25:Cài đặt gói công cụ Termux" > "$STATUS_FILE"
    apt-get update -y >> "$INSTALL_LOG" 2>&1 || true
    apt-get install -y --no-install-recommends proot-distro git curl nodejs jq tar openssl >> "$INSTALL_LOG" 2>&1 || true

    # 3. Cài đặt PRoot Ubuntu
    echo "45:Thiết lập PRoot Ubuntu" > "$STATUS_FILE"
    if ! is_ubuntu_installed; then
        proot-distro remove ubuntu >> "$INSTALL_LOG" 2>&1 || true
        rm -rf "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" \
               "$PREFIX/var/lib/proot-distro/containers/ubuntu" \
               "$HOME/.local/share/proot-distro/containers/ubuntu" 2>/dev/null || true
        proot-distro install ubuntu >> "$INSTALL_LOG" 2>&1 || proot-distro install ubuntu:24.04 >> "$INSTALL_LOG" 2>&1 || true
    fi

    # 4. Cấu hình liên kết /sdcard
    echo "70:Kết nối thư mục game /sdcard" > "$STATUS_FILE"
    local conf_dir="$PREFIX/etc/proot-distro"
    mkdir -p "$conf_dir"
    local override="$conf_dir/ubuntu.override.conf"
    if ! grep -q "/sdcard:/sdcard" "$override" 2>/dev/null; then
        echo "bind_directories+=('/sdcard:/sdcard')" >> "$override"
    fi

    # 5. Cấu hình môi trường bên trong Ubuntu (.NET SDK, công cụ)
    echo "85:Cấu hình .NET SDK & công cụ" > "$STATUS_FILE"
    tar -C "$SCRIPT_DIR" -cf - . | proot-distro login ubuntu -- bash -c 'mkdir -p /root/stardew-env && tar -C /root/stardew-env -xf -' >> "$INSTALL_LOG" 2>&1 || true
    proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh >> "$INSTALL_LOG" 2>&1 || true
    echo "100:Hoàn tất cài đặt môi trường" > "$STATUS_FILE"
    return 0
}

# Thanh tiến trình động duy nhất tự căn chỉnh theo độ rộng màn hình Termux (khi zoom)
run_install_progress() {
    local spin_chars=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
    local n_chars=${#spin_chars[@]}
    local i=0
    local cur_pct=5
    local cur_label="Đang chuẩn bị môi trường..."

    printf "\033[?25l"
    do_install </dev/null >/dev/null 2>&1 &
    local pid=$!

    while kill -0 "$pid" 2>/dev/null; do
        local cols
        cols=$(get_term_cols)

        # Tính độ rộng thanh tiến trình phù hợp khi zoom to
        local bar_w=12
        [ "$cols" -lt 48 ] && bar_w=8
        [ "$cols" -ge 65 ] && bar_w=16

        # Tính độ dài nhãn để không bao giờ bị tràn dòng (wrap line)
        local max_label_w=$(( cols - bar_w - 18 ))
        [ "$max_label_w" -lt 12 ] && max_label_w=12

        if [ -f "$STATUS_FILE" ]; then
            local status_line
            status_line=$(cat "$STATUS_FILE" 2>/dev/null || true)
            if [ -n "$status_line" ]; then
                local target_pct="${status_line%%:*}"
                local label="${status_line#*:}"
                [ -n "$label" ] && cur_label="$label"
                if [ -n "$target_pct" ] && [ "$target_pct" -ge 0 ] 2>/dev/null; then
                    if [ "$cur_pct" -lt "$target_pct" ]; then
                        cur_pct=$(( cur_pct + 1 ))
                    fi
                fi
            fi
        fi

        if [ "$cur_pct" -lt 95 ] && [ $(( i % 15 )) -eq 0 ]; then
            cur_pct=$(( cur_pct + 1 ))
        fi

        local filled=$(( cur_pct * bar_w / 100 ))
        local empty=$(( bar_w - filled ))
        local bar=""
        for ((b=0; b<filled; b++)); do bar="${bar}█"; done
        for ((b=0; b<empty; b++)); do bar="${bar}░"; done

        local display_label="${cur_label:0:$max_label_w}"
        local idx=$(( i % n_chars ))
        printf "\r  ${CYAN}%s${RESET} [${GREEN}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}%-*s${RESET}\033[K" \
            "${spin_chars[$idx]}" "$bar" "$cur_pct" "$max_label_w" "$display_label"
        i=$(( i + 1 ))
        sleep 0.08
    done

    wait "$pid"
    local exit_code=$?
    rm -f "$STATUS_FILE"
    printf "\033[?25h"

    local cols
    cols=$(get_term_cols)
    local bar_w=12
    [ "$cols" -lt 48 ] && bar_w=8
    [ "$cols" -ge 65 ] && bar_w=16
    local full_bar=""
    for ((b=0; b<bar_w; b++)); do full_bar="${full_bar}█"; done

    if [ "$exit_code" -eq 0 ]; then
        printf "\r  ${GREEN}✓${RESET} [${GREEN}%s${RESET}] ${BOLD}100%%${RESET}  ${WHITE}Cài đặt hoàn tất${RESET}\033[K\n" \
            "$full_bar"
        return 0
    else
        printf "\r  ${RED}✗${RESET} [${RED}%s${RESET}] ${BOLD}%3d%%${RESET}  ${WHITE}Cài đặt thất bại (mã %d)${RESET}\033[K\n" \
            "$bar" "$cur_pct" "$exit_code"
        if [ -f "$INSTALL_LOG" ]; then
            echo
            print_warning "Chi tiết lỗi:"
            tail -n 15 "$INSTALL_LOG"
            echo
        fi
        return "$exit_code"
    fi
}

echo
run_install_progress
echo
print_line
echo

# Khởi tạo tài khoản người dùng sudo & workspace
# Chạy trực tiếp với TTY chuẩn
if [ -f "$SCRIPT_DIR/scripts/init-user.sh" ]; then
    if [ -c /dev/tty ]; then
        proot-distro login ubuntu -- bash /root/stardew-env/scripts/init-user.sh < /dev/tty || true
    else
        proot-distro login ubuntu -- bash /root/stardew-env/scripts/init-user.sh || true
    fi
fi

# Lưu lại tên tài khoản mặc định trên Termux
SD_USER=$(proot-distro login ubuntu -- cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
if [ -n "$SD_USER" ]; then
    echo "$SD_USER" > "$PREFIX/etc/stardew-default-user"
fi

# Tạo binary lệnh 'ubuntu' trên Termux (nhẹ nhàng, chuẩn xác, không dùng process substitution)
mkdir -p "$PREFIX/bin"
cat << 'EOF' > "$PREFIX/bin/ubuntu"
#!/data/data/com.termux/files/usr/bin/bash
USER_FILE="$PREFIX/etc/stardew-default-user"
SD_USER=""
if [ -f "$USER_FILE" ]; then
    SD_USER=$(cat "$USER_FILE" 2>/dev/null | tr -d '[:space:]')
fi
if [ -n "$SD_USER" ]; then
    exec proot-distro login ubuntu --user "$SD_USER"
fi
exec proot-distro login ubuntu
EOF
chmod +x "$PREFIX/bin/ubuntu"

# Tạo các alias bổ sung
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" 2>/dev/null || true
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/stardew-code" 2>/dev/null || true

echo
print_box "Cài đặt thành công! Gõ 'ubuntu' để bắt đầu."
echo

if confirm_default_yes "Khởi động vào Ubuntu ngay bây giờ?"; then
    if [ -c /dev/tty ]; then
        exec "$PREFIX/bin/ubuntu" < /dev/tty
    else
        exec "$PREFIX/bin/ubuntu"
    fi
fi
