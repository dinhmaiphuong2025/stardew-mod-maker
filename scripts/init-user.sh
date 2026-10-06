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
banner "KHỞI TẠO NGƯỜI DÙNG" "Thiết lập tài khoản sudo cho không gian làm việc"

print_info "Khởi động lần đầu: Vui lòng thiết lập tài khoản người dùng cho Ubuntu."
echo

# 1. Nhập tên người dùng (hỗ trợ đọc từ /dev/tty khi chạy qua pipe)
printf "  Nhập tên người dùng (viết thường không dấu, mặc định: stardew): "
if [ -c /dev/tty ] && [ -r /dev/tty ]; then
    read -r INPUT_USER < /dev/tty 2>/dev/null || read -r INPUT_USER 2>/dev/null || INPUT_USER="stardew"
else
    read -r INPUT_USER 2>/dev/null || INPUT_USER="stardew"
fi
INPUT_USER=$(echo "$INPUT_USER" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9_-')
[ -z "$INPUT_USER" ] && INPUT_USER="stardew"

# 2. Nhập mật khẩu (tùy chọn)
printf "  Nhập mật khẩu (nhấn Enter để trống nếu không cần mật khẩu): "
if [ -c /dev/tty ] && [ -r /dev/tty ]; then
    read -rs INPUT_PASS < /dev/tty 2>/dev/null || read -rs INPUT_PASS 2>/dev/null || INPUT_PASS=""
else
    read -rs INPUT_PASS 2>/dev/null || INPUT_PASS=""
fi
echo

# 3. Hỏi tắt hỏi mật khẩu sudo
NOPASSWD=0
if confirm "  Tắt hỏi mật khẩu khi sử dụng sudo? (Khuyên dùng cho Termux)"; then
    NOPASSWD=1
fi

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

if [ -f "$TEMPLATE_SRC/docs/05-agent-tools.md" ]; then
    cp "$TEMPLATE_SRC/docs/05-agent-tools.md" "$USER_WORKSPACE/AGENT_GUIDE.md"
elif [ -f "/root/stardew-env/docs/05-agent-tools.md" ]; then
    cp /root/stardew-env/docs/05-agent-tools.md "$USER_WORKSPACE/AGENT_GUIDE.md"
fi

# Thêm banner khởi động vào .bashrc của user (gợi ý cài đặt Agent thay vì menu stardew-mod)
cat << 'EOF' >> "$USER_HOME/.bashrc"

if [ -f /usr/local/bin/ui.sh ]; then
    source /usr/local/bin/ui.sh
    clear_screen
    banner "STARDEW MOD VIBECODING" "Không gian sáng tạo Mod Cinderbox Android"
    print_info "Cài đặt AI Coding Agent mong muốn để bắt đầu:"
    echo "  • OpenCode CLI (lệnh 'opencode'):     stardew-mod agent opencode"
    echo "  • Antigravity CLI (lệnh 'agy'):       stardew-mod agent antigravity"
    echo
    print_info "Hoặc gõ 'stardew-mod agent' để chọn Claude Code, Codex, Hermes... kèm mô tả chi tiết."
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
print_box "Không gian làm việc: $USER_WORKSPACE"
echo
sleep 1
