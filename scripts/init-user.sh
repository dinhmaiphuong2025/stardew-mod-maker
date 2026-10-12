#!/usr/bin/env bash
# ==============================================================================
# Script khởi tạo tài khoản người dùng sudo cho PRoot Ubuntu
# Tuân thủ UI Style Shell (ui-style-shell) - Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

export LC_ALL=C.UTF-8
export LANG=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -f "/usr/local/bin/ui.sh" ]; then
    source "/usr/local/bin/ui.sh"
elif [ -f "$SCRIPT_DIR/ui.sh" ]; then
    source "$SCRIPT_DIR/ui.sh"
fi

if [ -f "/etc/stardew-user-created" ]; then
    exit 0
fi

clear_screen
banner "KHỞI TẠO TÀI KHOẢN" "Thiết lập quyền sudo cho không gian làm việc Ubuntu"

# 1. Nhập tên tài khoản (mặc định stardew)
printf "  ${CYAN}❯${RESET} Tên người dùng [mặc định: ${YELLOW}stardew${RESET}]: "
if [ -c /dev/tty ] && [ -r /dev/tty ]; then
    read -r INPUT_USER < /dev/tty 2>/dev/null || read -r INPUT_USER 2>/dev/null || INPUT_USER="stardew"
else
    read -r INPUT_USER 2>/dev/null || INPUT_USER="stardew"
fi
INPUT_USER=$(echo "$INPUT_USER" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')
[ -z "$INPUT_USER" ] && INPUT_USER="stardew"

# 2. Nhập mật khẩu (nhấn Enter để bỏ qua)
printf "  ${CYAN}❯${RESET} Mật khẩu sudo [nhấn Enter để bỏ qua]: "
if [ -c /dev/tty ] && [ -r /dev/tty ]; then
    read -rs INPUT_PASS < /dev/tty 2>/dev/null || read -rs INPUT_PASS 2>/dev/null || INPUT_PASS=""
else
    read -rs INPUT_PASS 2>/dev/null || INPUT_PASS=""
fi
echo

# 3. Miễn hỏi mật khẩu sudo (mặc định Y)
NOPASSWD=1
NOPASSWD_TEXT="Có"
printf "  ${CYAN}❯${RESET} Miễn hỏi mật khẩu khi sudo? (Y/n) [${GREEN}Y${RESET}]: "
CONFIRM_SUDO=""
if [ -c /dev/tty ] && [ -r /dev/tty ]; then
    read -r CONFIRM_SUDO < /dev/tty 2>/dev/null || read -r CONFIRM_SUDO 2>/dev/null || CONFIRM_SUDO="y"
else
    read -r CONFIRM_SUDO 2>/dev/null || CONFIRM_SUDO="y"
fi
[ -z "$CONFIRM_SUDO" ] && CONFIRM_SUDO="y"
case "$CONFIRM_SUDO" in
    [nN]|[nN][oO])
        NOPASSWD=0
        NOPASSWD_TEXT="Không"
        ;;
    *)
        NOPASSWD=1
        NOPASSWD_TEXT="Có"
        ;;
esac

echo
print_info "Đang khởi tạo tài khoản '$INPUT_USER'..."

# Tạo user nếu chưa tồn tại
if ! id "$INPUT_USER" >/dev/null 2>&1; then
    useradd -m -s /bin/bash -G sudo,users "$INPUT_USER"
fi

# Thiết lập mật khẩu
if [ -n "$INPUT_PASS" ]; then
    echo "$INPUT_USER:$INPUT_PASS" | chpasswd
else
    passwd -d "$INPUT_USER" >/dev/null 2>&1 || true
fi

# Cấu hình sudoers
mkdir -p /etc/sudoers.d
if [ "$NOPASSWD" -eq 1 ] || [ -z "$INPUT_PASS" ]; then
    echo "$INPUT_USER ALL=(ALL) NOPASSWD:ALL" > "/etc/sudoers.d/$INPUT_USER"
else
    echo "$INPUT_USER ALL=(ALL:ALL) ALL" > "/etc/sudoers.d/$INPUT_USER"
fi
chmod 0440 "/etc/sudoers.d/$INPUT_USER"

# Thiết lập thư mục workspace riêng biệt trong /home/$INPUT_USER
USER_HOME="/home/$INPUT_USER"
USER_WORKSPACE="$USER_HOME/stardew-workspace"
mkdir -p "$USER_WORKSPACE"
mkdir -p "$USER_WORKSPACE/mods"
mkdir -p "$USER_WORKSPACE/lib"

# Ánh xạ bộ nhớ thiết bị Android (/sdcard) trực tiếp vào thư mục người dùng
ln -sfn /sdcard "$USER_HOME/sdcard" 2>/dev/null || true
ln -sfn /sdcard/StardewValley "$USER_WORKSPACE/game" 2>/dev/null || true
ln -sfn /sdcard/StardewValley/desktop/Mods "$USER_WORKSPACE/installed-mods" 2>/dev/null || true

TEMPLATE_SRC="/usr/local/share/stardew-template"
if [ -d "$TEMPLATE_SRC/templates" ]; then
    cp -r "$TEMPLATE_SRC/templates" "$USER_WORKSPACE/"
elif [ -d "/root/stardew-env/templates" ]; then
    cp -r /root/stardew-env/templates "$USER_WORKSPACE/"
fi

if [ -f "$TEMPLATE_SRC/VIBECODE_PROMPT_TEMPLATE.md" ]; then
    cp "$TEMPLATE_SRC/VIBECODE_PROMPT_TEMPLATE.md" "$USER_WORKSPACE/"
elif [ -f "/root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md" ]; then
    cp /root/stardew-env/VIBECODE_PROMPT_TEMPLATE.md "$USER_WORKSPACE/"
fi

if [ -f "$TEMPLATE_SRC/AGENTS.md" ]; then
    cp "$TEMPLATE_SRC/AGENTS.md" "$USER_WORKSPACE/AGENTS.md"
elif [ -f "/root/stardew-env/AGENTS.md" ]; then
    cp /root/stardew-env/AGENTS.md "$USER_WORKSPACE/AGENTS.md"
fi

# Thêm banner khởi động vào .bashrc của user (Tự động thích ứng thông minh)
cat << 'EOF' >> "$USER_HOME/.bashrc"

if [ -f /usr/local/bin/ui.sh ]; then
    source /usr/local/bin/ui.sh
    clear_screen
    banner "STARDEW MOD VIBECODING" "Không gian sáng tạo Mod Cinderbox Android"

    # Kiểm tra xem AI Agent nào đã được cài đặt
    INSTALLED_AGENT=""
    if command -v opencode >/dev/null 2>&1; then
        INSTALLED_AGENT="opencode"
    elif command -v agy >/dev/null 2>&1; then
        INSTALLED_AGENT="agy"
    elif command -v claude >/dev/null 2>&1; then
        INSTALLED_AGENT="claude"
    fi

    if [ -n "$INSTALLED_AGENT" ]; then
        echo -e "  ${GREEN}✓${RESET} AI Agent sẵn sàng: ${BOLD}${YELLOW}$INSTALLED_AGENT${RESET}"
        echo -e "  ${CYAN}•${RESET} Khởi động AI:      ${BOLD}${YELLOW}$INSTALLED_AGENT${RESET}"
        echo -e "  ${CYAN}•${RESET} Tạo mod mới:       ${BOLD}${WHITE}stardew-mod new <TênMod>${RESET}"
        echo -e "  ${CYAN}•${RESET} Xem danh sách mod: ${BOLD}${WHITE}stardew-mod list${RESET}"
        echo -e "  ${CYAN}•${RESET} Xem log lỗi game:  ${BOLD}${WHITE}stardew-mod logs${RESET}"
    else
        print_info "Cài đặt AI Coding Agent để bắt đầu:"
        echo -e "  ${CYAN}•${RESET} OpenCode CLI v2: ${BOLD}${YELLOW}stardew-mod agent opencode${RESET}"
        echo -e "  ${CYAN}•${RESET} Antigravity CLI: ${BOLD}${YELLOW}stardew-mod agent antigravity${RESET}"
        echo -e "  ${CYAN}•${RESET} Danh sách Agent: ${BOLD}${YELLOW}stardew-mod agent${RESET}"
        echo -e "  ${CYAN}•${RESET} Hướng dẫn lệnh:  ${BOLD}${YELLOW}stardew-mod help${RESET}"
    fi
    print_line
fi
cd ~/stardew-workspace
EOF

# Đảm bảo phân quyền toàn bộ thuộc về user mới (không bị dính quyền root)
chown -R "$INPUT_USER:$INPUT_USER" "$USER_HOME"

# Đánh dấu đã tạo user và lưu tên user mặc định
echo "$INPUT_USER" > /etc/stardew-default-user
touch /etc/stardew-user-created

echo
print_success "Đã tạo tài khoản '$INPUT_USER' và cấp quyền sudo thành công!"
echo -e "  ${CYAN}•${RESET} Không gian làm việc:  ${BOLD}${WHITE}$USER_WORKSPACE${RESET}"
echo -e "  ${CYAN}•${RESET} Miễn mật khẩu sudo:    ${YELLOW}$NOPASSWD_TEXT${RESET}"
echo -e "  ${CYAN}•${RESET} Thư mục game /sdcard: ${GRAY}/sdcard/StardewValley${RESET}"
echo
sleep 1
