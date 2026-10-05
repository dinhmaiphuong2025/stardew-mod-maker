#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Chạy trực tiếp trên Termux (Không cần Root, Không cần Droidspaces)
# ==============================================================================

set -e

# Màu sắc hiển thị
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}================================================================${NC}"
echo -e "${GREEN}   ★ CHÀO MỪNG BẠN ĐẾN VỚI BỘ CÀI ĐẶT STARDEW MOD VIBECODING ★   ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e "${YELLOW}Hệ thống sẽ tự động cấu hình môi trường PRoot Ubuntu để bạn có thể${NC}"
echo -e "${YELLOW}dùng AI (ChatGPT/Claude/Gemini/AI CLI) tự tạo mod cho Cinderbox!${NC}\n"

# 1. Kiểm tra môi trường Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    echo -e "${RED}[!] Lỗi: Script này cần được chạy trên Termux của Android!${NC}"
    exit 1
fi

# 2. Yêu cầu cấp quyền bộ nhớ thiết bị
echo -e "${BLUE}[1/5] Kiểm tra và cấp quyền truy cập bộ nhớ điện thoại (/sdcard)...${NC}"
if [ ! -d "$HOME/storage/shared" ]; then
    echo -e "${YELLOW}Vui lòng chọn 'CHO PHÉP' (ALLOW) trên cửa sổ hiện lên của Android...${NC}"
    termux-setup-storage
    sleep 3
fi

# 3. Cập nhật và cài đặt các gói cần thiết trên Termux
echo -e "${BLUE}[2/5] Đang cài đặt công cụ nền tảng cho Termux...${NC}"
pkg update -y
pkg install -y proot-distro git curl nodejs jq tar

# 4. Cài đặt hệ điều hành PRoot Ubuntu
echo -e "${BLUE}[3/5] Đang kiểm tra hệ điều hành Ubuntu trong PRoot...${NC}"
if proot-distro list | grep -q "ubuntu (installed)"; then
    echo -e "${GREEN}✓ PRoot Ubuntu đã được cài đặt từ trước.${NC}"
else
    echo -e "${YELLOW}Đang tải và cài đặt Ubuntu (khoảng 1-2 phút tùy mạng)...${NC}"
    proot-distro install ubuntu
fi

# 5. Cấu hình tự động Mount /sdcard vào Ubuntu
echo -e "${BLUE}[4/5] Cấu hình tự động kết nối thư mục /sdcard...${NC}"
CONF_DIR="$PREFIX/etc/proot-distro"
mkdir -p "$CONF_DIR"
OVERRIDE_FILE="$CONF_DIR/ubuntu.override.conf"

if ! grep -q "/sdcard:/sdcard" "$OVERRIDE_FILE" 2>/dev/null; then
    echo "bind_directories+=('/sdcard:/sdcard')" >> "$OVERRIDE_FILE"
    echo -e "${GREEN}✓ Đã cấu hình mount /sdcard vào container Ubuntu.${NC}"
else
    echo -e "${GREEN}✓ Cấu hình mount /sdcard đã sẵn sàng.${NC}"
fi

# 6. Sao chép bộ công cụ vào bên trong Ubuntu và kích hoạt cài đặt giai đoạn 2
echo -e "${BLUE}[5/5] Cài đặt .NET SDK và môi trường VibeCoding bên trong Ubuntu...${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"

mkdir -p "$UBUNTU_ROOT/root/stardew-env"
cp -r "$SCRIPT_DIR/"* "$UBUNTU_ROOT/root/stardew-env/"

# Chạy script setup bên trong PRoot
proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh

# Tạo lệnh tắt cho Termux để truy cập nhanh
cat << 'EOF' > "$PREFIX/bin/stardew-code"
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu --workdir /root/stardew-workspace
EOF
chmod +x "$PREFIX/bin/stardew-code"

echo -e "\n${CYAN}================================================================${NC}"
echo -e "${GREEN}   ★ CÀI ĐẶT HOÀN TẤT THÀNH CÔNG! SẴN SÀNG VIBECODING ★   ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo -e "${YELLOW}Từ giờ, mỗi khi muốn code mod hoặc ra lệnh cho AI, bạn chỉ cần gõ:${NC}"
echo -e "   ${GREEN}stardew-code${NC}"
echo -e "\n${YELLOW}Lệnh này sẽ đưa bạn thẳng vào workspace bên trong Ubuntu.${NC}"
echo -e "${YELLOW}Tại đó, bạn có thể gõ ${GREEN}stardew-mod new <TenMod>${YELLOW} để tạo mod mới!${NC}\n"
