#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Tuân thủ UI Style Shell (ui-style-shell) - Ký tự Braille & Tiếng Việt đầy đủ dấu
# ==============================================================================

set -e

export PROOT_NO_SECCOMP=1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
REPO_DIR="$HOME/.stardew-proot-vibecoding"

# Tự động nạp mã nguồn khi chạy trực tiếp qua: curl ... | bash
if [ ! -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    printf "Đang chuẩn bị gói cài đặt từ GitHub...\n"
    pkg update -y >/dev/null 2>&1 || true
    pkg install -y git curl jq tar >/dev/null 2>&1
    rm -rf "$REPO_DIR"
    git clone --depth 1 https://github.com/dinhmaiphuong2025/stardew-proot-vibecoding.git "$REPO_DIR" >/dev/null 2>&1

    if [ -c /dev/tty ] && [ -r /dev/tty ]; then
        exec bash "$REPO_DIR/install.sh" "$@" < /dev/tty
    else
        exec bash "$REPO_DIR/install.sh" "$@"
    fi
fi

# Tải thư viện UI style
source "$SCRIPT_DIR/scripts/ui.sh"

# Hàm kiểm tra container ubuntu tồn tại
is_ubuntu_installed() {
    if proot-distro login ubuntu -- true 2>/dev/null; then
        return 0
    fi
    if proot-distro list -q 2>/dev/null | grep -qx "ubuntu"; then
        return 0
    fi
    if proot-distro list 2>/dev/null | grep -E "(^|[[:space:]])ubuntu($|[[:space:]]|\()"; then
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

# 2. Khởi tạo thanh tiến trình động duy nhất (không tách làm nhiều thanh)
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

# Bước 3: Cài đặt PRoot Ubuntu
setup_ubuntu_distro() {
    if ! is_ubuntu_installed; then
        proot-distro install ubuntu >/dev/null 2>&1 || true
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
    tar -C "$SCRIPT_DIR" -cf - . | proot-distro login ubuntu -- bash -c 'mkdir -p /root/stardew-env && tar -C /root/stardew-env -xf -' >/dev/null 2>&1
    proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh >/dev/null 2>&1
}
step_task "Cấu hình .NET 10.0 SDK và công cụ bên trong Ubuntu" setup_container_env

finish_progress
echo

# Khởi tạo tài khoản người dùng sudo & workspace
if [ -f "$SCRIPT_DIR/scripts/init-user.sh" ]; then
    proot-distro login ubuntu -- bash /root/stardew-env/scripts/init-user.sh 2>&1 | grep -v "can't sanitize binding" || true
else
    proot-distro login ubuntu -- bash /usr/local/bin/init-user.sh 2>&1 | grep -v "can't sanitize binding" || true
fi

# Lưu lại tên tài khoản mặc định trên Termux
SD_USER=$(proot-distro login ubuntu -- cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
if [ -n "$SD_USER" ]; then
    echo "$SD_USER" > "$PREFIX/etc/stardew-default-user"
fi

# Tạo binary lệnh 'ubuntu' trên Termux (lọc cảnh báo sanitize binding)
mkdir -p "$PREFIX/bin"
cat << 'EOF' > "$PREFIX/bin/ubuntu"
#!/data/data/com.termux/files/usr/bin/bash
export PROOT_NO_SECCOMP=1
USER_FILE="$PREFIX/etc/stardew-default-user"
SD_USER=""
if [ -f "$USER_FILE" ]; then
    SD_USER=$(cat "$USER_FILE" 2>/dev/null | tr -d '[:space:]')
fi
if [ -z "$SD_USER" ]; then
    SD_USER=$(proot-distro login ubuntu -- cat /etc/stardew-default-user 2>/dev/null | tr -d '[:space:]')
fi
if [ -n "$SD_USER" ]; then
    exec proot-distro login ubuntu --user "$SD_USER" 2> >(grep -v "can't sanitize binding" >&2)
fi
exec proot-distro login ubuntu 2> >(grep -v "can't sanitize binding" >&2)
EOF
chmod +x "$PREFIX/bin/ubuntu"

# Tạo các alias bổ sung
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/Ubuntu" 2>/dev/null || true
cp -f "$PREFIX/bin/ubuntu" "$PREFIX/bin/stardew-code" 2>/dev/null || true

echo
print_box "Cài đặt hoàn tất! Gõ 'ubuntu' để vào môi trường làm việc."
echo

if confirm "Khởi động vào Ubuntu ngay bây giờ?"; then
    exec "$PREFIX/bin/ubuntu"
fi
