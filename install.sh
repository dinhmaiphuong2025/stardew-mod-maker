#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Tuân thủ UI Style Shell (ui-style-shell) - Ký tự Braille & Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8
export PROOT_NO_SECCOMP=1

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$HOME/.stardew-mod-maker"

# Tự động nạp mã nguồn khi chạy trực tiếp qua: curl ... | bash
if [ ! -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    printf "Đang chuẩn bị gói cài đặt từ GitHub...\n"
    pkg update -y >/dev/null 2>&1 || true
    pkg install -y git curl jq tar >/dev/null 2>&1
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
    print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
    print_prompt() { printf "${GREEN}❯ ${RESET}" >&2; }
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

# 2. Khởi tạo thanh tiến trình động duy nhất
init_progress 5
echo

# Bước 1: Quyền truy cập bộ nhớ
check_storage() {
    if [ ! -d "$HOME/storage/shared" ]; then
        termux-setup-storage >/dev/null 2>&1 || true
        sleep 2
    fi
    [ -d "$HOME/storage/shared" ] || [ -d "/sdcard" ]
}
step_task "Kiểm tra quyền truy cập bộ nhớ /sdcard" check_storage

# Bước 2: Cài đặt gói công cụ Termux
step_task "Cài đặt các gói công cụ nền tảng Termux" bash -c "pkg update -y >/dev/null 2>&1 && pkg install -y proot-distro git curl nodejs jq tar >/dev/null 2>&1"

# Bước 3: Cài đặt PRoot Ubuntu (tự động dọn dẹp nếu container bị lỗi trước đó)
setup_ubuntu_distro() {
    if ! is_ubuntu_installed; then
        proot-distro remove ubuntu >/dev/null 2>&1 || true
        rm -rf "$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu" \
               "$PREFIX/var/lib/proot-distro/containers/ubuntu" \
               "$HOME/.local/share/proot-distro/containers/ubuntu" 2>/dev/null || true
        proot-distro install ubuntu >/dev/null 2>&1 || proot-distro install ubuntu:24.04 >/dev/null 2>&1 || true
    fi
    is_ubuntu_installed
}
step_task "Thiết lập hệ điều hành PRoot Ubuntu" setup_ubuntu_distro

# Bước 4: Cấu hình liên kết /sdcard
setup_mounts() {
    local conf_dir="$PREFIX/etc/proot-distro"
    mkdir -p "$conf_dir"
    local override="$conf_dir/ubuntu.override.conf"
    if ! grep -q "/sdcard:/sdcard" "$override" 2>/dev/null; then
        echo "bind_directories+=('/sdcard:/sdcard')" >> "$override"
    fi
}
step_task "Cấu hình tự động kết nối thư mục game /sdcard" setup_mounts

# Bước 5: Cấu hình môi trường bên trong container (.NET SDK, công cụ)
setup_container_env() {
    tar -C "$SCRIPT_DIR" -cf - . | proot-distro login ubuntu -- bash -c 'mkdir -p /root/stardew-env && tar -C /root/stardew-env -xf -' >/dev/null 2>&1 || true
    proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh >/dev/null 2>&1 || true
}
step_task "Cấu hình .NET 10.0 SDK và công cụ bên trong Ubuntu" setup_container_env

finish_progress
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

if confirm "Khởi động vào Ubuntu ngay bây giờ?"; then
    if [ -c /dev/tty ]; then
        exec "$PREFIX/bin/ubuntu" < /dev/tty
    else
        exec "$PREFIX/bin/ubuntu"
    fi
fi
