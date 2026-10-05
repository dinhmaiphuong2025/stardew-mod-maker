#!/data/data/com.termux/files/usr/bin/bash
# ==============================================================================
# Bộ cài đặt 1-Click: Môi trường VibeCoding Mod Stardew Valley trên Android
# Tuân thủ UI Style Shell (ui-style-shell)
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Tải thư viện UI style
if [ -f "$SCRIPT_DIR/scripts/ui.sh" ]; then
    source "$SCRIPT_DIR/scripts/ui.sh"
else
    RESET='\033[0m'   BOLD='\033[1m'    GRAY='\033[90m'
    RED='\033[1;31m'  GREEN='\033[1;32m' YELLOW='\033[1;33m'
    BLUE='\033[1;34m' CYAN='\033[1;36m'  WHITE='\033[1;37m'
    clear_screen() { printf "\033[2J\033[H"; }
    print_line() { printf "${GRAY}─────────────────────────────────────────────────────────────${RESET}\n"; }
    print_prompt() { printf "${GREEN}❯ ${RESET}"; }
    print_success() { printf "${GREEN}✓ %s${RESET}\n" "$1"; }
    print_error() { printf "${RED}✗ %s${RESET}\n" "$1"; }
    print_warning() { printf "${YELLOW}⚠ %s${RESET}\n" "$1"; }
    print_info() { printf "${BLUE}ℹ %s${RESET}\n" "$1"; }
    banner() {
        printf "      ${BOLD}${WHITE}%s${RESET}\n" "$1"
        [ -n "$2" ] && printf "      ${GRAY}%s${RESET}\n" "$2"
        print_line
    }
    print_box() {
        local len=${#1} border=""
        for ((i=0; i<len+2; i++)); do border="${border}─"; done
        printf "  ${GRAY}┌%s┐${RESET}\n  ${GRAY}│${RESET} %s ${GRAY}│${RESET}\n  ${GRAY}└%s┘${RESET}\n" "$border" "$1" "$border"
    }
    spinner_animate() { sleep 0.5; }
    print_progress_bar() { printf "\r  %s %3d%%" "$1" "$(( $2 * 100 / $3 ))"; }
fi

clear_screen
banner "STARDEW MOD VIBECODING" "Cai dat moi truong Termux & PRoot Ubuntu"

# 1. Kiem tra Termux
if [ -z "$PREFIX" ] || [ ! -d "$PREFIX" ]; then
    print_error "Script nay phai duoc chay ben trong ung dung Termux tren Android."
    exit 1
fi
print_success "Moi truong Termux xac thuc thanh cong."

# 2. Quyen truy cap bo nho
print_info "Kiem tra quyen truy cap bo nho thiet bi..."
if [ ! -d "$HOME/storage/shared" ]; then
    print_warning "Vui long chon 'Cho phep' tren hop thoai he thong..."
    termux-setup-storage
    sleep 2
fi
print_success "Quyen truy cap bo nho /sdcard da san sang."

# 3. Cai dat goi nen tang Termux
print_info "Cai dat cac goi nen tang: proot-distro, git, curl, jq, tar..."
pkg update -y >/dev/null 2>&1 || true
pkg install -y proot-distro git curl nodejs jq tar >/dev/null 2>&1
print_success "Cac goi Termux co ban da duoc cai dat."

# 4. Kiem tra va cai dat PRoot Ubuntu
print_info "Kiem tra he dieu hanh PRoot Ubuntu..."
if proot-distro list | grep -q "ubuntu (installed)"; then
    print_success "PRoot Ubuntu da ton tai tren he thong."
else
    print_info "Dang tai va cai dat Ubuntu aarch64 (co the mat 1-2 phut)..."
    proot-distro install ubuntu
    print_success "Cai dat Ubuntu thanh cong."
fi

# 5. Cau hinh tu dong mount /sdcard
print_info "Cau hinh tu dong ket noi thu muc /sdcard..."
CONF_DIR="$PREFIX/etc/proot-distro"
mkdir -p "$CONF_DIR"
OVERRIDE_FILE="$CONF_DIR/ubuntu.override.conf"

if ! grep -q "/sdcard:/sdcard" "$OVERRIDE_FILE" 2>/dev/null; then
    echo "bind_directories+=('/sdcard:/sdcard')" >> "$OVERRIDE_FILE"
fi
print_success "Lien ket bo nho /sdcard:/sdcard da san sang."

# 6. Sao chep bo cong cu vao Ubuntu va khoi chay setup-proot
print_info "Dong bo ma nguon va thiet lap moi truong ben trong container..."
UBUNTU_ROOT="$PREFIX/var/lib/proot-distro/installed-rootfs/ubuntu"
mkdir -p "$UBUNTU_ROOT/root/stardew-env"
cp -r "$SCRIPT_DIR/"* "$UBUNTU_ROOT/root/stardew-env/"

proot-distro login ubuntu -- bash /root/stardew-env/scripts/setup-proot.sh

# 7. Tao lenh tat tren Termux
cat << 'EOF' > "$PREFIX/bin/stardew-code"
#!/data/data/com.termux/files/usr/bin/bash
proot-distro login ubuntu --workdir /root/stardew-workspace
EOF
chmod +x "$PREFIX/bin/stardew-code"

echo
print_line
print_box "Cai dat hoan tat! Go 'stardew-code' de vao workspace."
echo
