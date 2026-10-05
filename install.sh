#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Tuân thủ UI Style Shell (ui-style-shell) - Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$HOME/.stardew-proot-vibecoding"

# Tự động nạp mã nguồn khi chạy trực tiếp qua: curl ... | bash
if [ ! -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    echo "Đang chuẩn bị gói cài đặt từ GitHub..."
    pkg update -y >/dev/null 2>&1 || true
    pkg install -y git curl jq tar >/dev/null 2>&1
    rm -rf "$REPO_DIR"
    git clone --depth 1 https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git "$REPO_DIR"

    if [ -c /dev/tty ] && [ -r /dev/tty ]; then
        exec bash "$REPO_DIR/install.sh" "$@" < /dev/tty
    else
        exec bash "$REPO_DIR/install.sh" "$@"
    fi
fi

# Tải thư viện UI style
source "$SCRIPT_DIR/scripts/ui.sh"

clear_screen
banner "STARDEW MOD VIBECODING" "Cài đặt tự động môi trường Termux & PRoot Ubuntu"

# 1. Kiểm tra môi trường Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    print_error "Kịch bản này bắt buộc phải được chạy bên trong ứng dụng Termux trên Android."
    exit 1
fi
print_success "Môi trường Termux hợp lệ."

# Bước 1: Quyền truy cập bộ nhớ
print_step_bar 1 6 "Kiểm tra quyền truy cập bộ nhớ thiết bị"
if [ ! -d "$HOME/storage/shared" ]; then
    print_warning "Vui lòng chọn 'Cho phép' (Allow) trên hộp thoại hệ thống..."
    termux-setup-storage
    sleep 2
fi
print_success "Quyền truy cập bộ nhớ /sdcard đã sẵn sàng."

# Bước 2: Cài đặt gói nền tảng Termux
print_step_bar 2 6 "Cài đặt các gói công cụ nền tảng Termux"
spin_task "Cập nhật danh sách kho gói Termux" pkg update -y
spin_task "Cài đặt proot-distro, git, curl, nodejs, jq, tar" pkg install -y proot-distro git curl nodejs jq tar

# Bước 3: Cài đặt PRoot Ubuntu
print_step_bar 3 6 "Cài đặt hệ điều hành PRoot Ubuntu aarch64"
if proot-distro list 2>/dev/null | grep -q "ubuntu.*installed"; then
    print_success "PRoot Ubuntu đã tồn tại sẵn trên thiết bị."
else
    spin_task "Tải về và giải nén PRoot Ubuntu aarch64" proot-distro install ubuntu
fi

# Bước 4: Cấu hình liên kết thư mục /sdcard
print_step_bar 4 6 "Cấu hình tự động kết nối thư mục /sdcard"
CONF_DIR="$PREFIX/etc/proot-distro"
mkdir -p "$CONF_DIR"
OVERRIDE_FILE="$CONF_DIR/ubuntu.override.conf"

if ! grep -q "/sdcard:/sdcard" "$OVERRIDE_FILE" 2>/dev/null; then
    echo "bind_directories+=('/sdcard:/sdcard')" >> "$OVERRIDE_FILE"
fi
print_success "Liên kết lưu trữ /sdcard:/sdcard đã sẵn sàng."

# Bước 5: Cấu hình môi trường bên trong Ubuntu (Sử dụng tar pipe để tương thích mọi phiên bản)
print_step_bar 5 6 "Thiết lập .NET 10.0 SDK và công cụ hệ thống"
spin_task "Đồng bộ mã nguồn vào container" bash -c "tar -C '$SCRIPT_DIR' -cf - . | proot-distro login ubuntu -- bash -c 'mkdir -p /root/stardew-env && tar -C /root/stardew-env -xf -'"

spin_task "Cài đặt .NET 10 SDK và đồng bộ thư viện" proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh

# Bước 6: Khởi tạo tài khoản người dùng sudo & workspace
print_step_bar 6 6 "Khởi tạo tài khoản sudo và không gian làm việc"
proot-distro login ubuntu -- bash /usr/local/bin/init-user.sh

# Lưu lại tên tài khoản mặc định trên Termux
SD_USER=$(proot-distro login ubuntu -- cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
if [ -n "$SD_USER" ]; then
    echo "$SD_USER" > "$PREFIX/etc/stardew-default-user"
fi

# Tạo binary lệnh 'ubuntu' trên Termux (chỉ cần gõ 'ubuntu' là vào proot)
mkdir -p "$PREFIX/bin"
cat << 'EOF' > "$PREFIX/bin/ubuntu"
#!/data/data/com.termux/files/usr/bin/bash
USER_FILE="$PREFIX/etc/stardew-default-user"
SD_USER=""
if [ -f "$USER_FILE" ]; then
    SD_USER=$(cat "$USER_FILE" 2>/dev/null | tr -d '[:space:]')
fi
if [ -z "$SD_USER" ]; then
    SD_USER=$(proot-distro login ubuntu -- cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
fi
if [ -n "$SD_USER" ]; then
    exec proot-distro login ubuntu --user "$SD_USER" --workdir "/home/$SD_USER/stardew-workspace"
fi
exec proot-distro login ubuntu
EOF
chmod +x "$PREFIX/bin/ubuntu"

# Tạo các alias bổ sung
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" 2>/dev/null || true
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/stardew-code" 2>/dev/null || true

echo
print_line
print_box "Cài đặt thành công! Từ giờ bạn chỉ cần gõ 'ubuntu' để vào proot."
echo

if confirm "Bạn có muốn khởi động vào Ubuntu ngay bây giờ?"; then
    exec "$PREFIX/bin/ubuntu"
fi
